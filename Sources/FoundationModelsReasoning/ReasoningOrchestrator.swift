//
//  ReasoningOrchestrator.swift
//  FoundationModelsReasoning
//

import Foundation
import FoundationModels

/// Coordinates generation of reasoning items and streams live snapshots
/// that a UI can render incrementally.
public actor ReasoningOrchestrator {

    private let generator = ReasoningItemGenerator()
    private let completenessEvaluator = ReasoningCompletenessEvaluator()
    private let similarityEvaluator = SimilarityEvaluator()
    private let repetitionEvaluator = ReasoningRepetitionEvaluator()

    private var additionalItemsNeeded = 0
    private var itemsUntilNextEval = 0
    private(set) var acceptedItems: [ConversationReasoningItem] = []
    // Public accessor for callers outside the actor.
    public var finalItems: [ConversationReasoningItem] { acceptedItems }

    /// Returns a stream of reasoning-list snapshots. Each element contains
    /// `ConversationReasoningItem.PartiallyGenerated` instances so callers can
    /// render "AI-typing" effects.
    nonisolated public func reason(
        for message: ConversationMessage,
        in conversation: Conversation
    ) -> AsyncThrowingStream<[ConversationReasoningItem.PartiallyGenerated], Error> {

        AsyncThrowingStream { continuation in
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    await self.resetAcceptedItems()
                    try await self.initialEvaluation(for: message, in: conversation)

                    try await self.produce(
                        message: message,
                        conversation: conversation,
                        current: await self.acceptedItems,
                        continuation: continuation
                    )

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func resetAcceptedItems() {
        acceptedItems = []
    }

    private func initialEvaluation(
        for message: ConversationMessage,
        in conversation: Conversation
    ) async throws {
        let temp = Conversation(
            with: conversation.session,
            messages: conversation.messages + [message]
        )
        let eval = try await completenessEvaluator.evaluate(temp)
        additionalItemsNeeded = eval.additionalReasoningItemsNeededEstimate
        itemsUntilNextEval = eval.numberOfReasoningItemsUntilNextEvaluation
    }

    private func reEvaluateCompleteness(
        message: ConversationMessage,
        conversation: Conversation
    ) async throws {
        let tempMsg = ConversationMessage(
            role: message.role,
            content: acceptedItems.map { $0 as any ConversationItem }
        )
        let temp = Conversation(
            with: conversation.session,
            messages: conversation.messages + [tempMsg]
        )
        let eval = try await completenessEvaluator.evaluate(temp)
        additionalItemsNeeded = eval.additionalReasoningItemsNeededEstimate
        itemsUntilNextEval = eval.numberOfReasoningItemsUntilNextEvaluation
    }

    // MARK: - Production loop

    private func produce(
        message: ConversationMessage,
        conversation: Conversation,
        current: [ConversationReasoningItem],
        continuation: AsyncThrowingStream<
            [ConversationReasoningItem.PartiallyGenerated],
            Error
        >.Continuation
    ) async throws {

        // Stop condition
        guard additionalItemsNeeded > 0 else { return }

        // Build prompt context with current items
        let msgWithContent = ConversationMessage(
            role: message.role,
            content: current.map { $0 as any ConversationItem }
        )
        let temp = Conversation(
            with: conversation.session,
            messages: conversation.messages + [msgWithContent]
        )

        // Begin streaming next reasoning item
        let stream = try await generator.generate(from: temp)

        // Live list with placeholder for the in-flight item
        var live = current.map { $0.asPartiallyGenerated() }
        live.append(
            ConversationReasoningItem(
                reasoningContent: "",
                title: "",
                evalNeeded: false
            ).asPartiallyGenerated()
        )
        continuation.yield(live)
        let placeholderIdx = live.index(before: live.endIndex)

        // Forward partial tokens
        for try await partial in stream {
            live[placeholderIdx] = partial
            continuation.yield(live)
        }

        // Stream finished – collect the fully-formed item
        let finalized = try await stream.collect().content

        // Decide whether to accept
        if try await shouldReject(
            candidate: finalized,
            conversation: conversation,
            message: message,
            currentItems: current
        ) {
            // Drop placeholder and regenerate
            continuation.yield(Array(live.dropLast()))
            try await produce(
                message: message,
                conversation: conversation,
                current: current,
                continuation: continuation
            )
            return
        }

        acceptedItems = current + [finalized]
        continuation.yield(acceptedItems.map { $0.asPartiallyGenerated() })

        // Book-keeping
        additionalItemsNeeded -= 1
        itemsUntilNextEval -= 1
        if finalized.evalNeeded { itemsUntilNextEval = 0 }

        // Re-evaluate completeness if requested
        if additionalItemsNeeded > 0 && itemsUntilNextEval <= 0 {
            try await reEvaluateCompleteness(message: message, conversation: conversation)
        }

        // Recurse for the next item
        try await produce(
            message: message,
            conversation: conversation,
            current: acceptedItems,
            continuation: continuation
        )
    }

    // MARK: - Redundancy checking

    private func shouldReject(
        candidate: ConversationReasoningItem,
        conversation: Conversation,
        message: ConversationMessage,
        currentItems: [ConversationReasoningItem]
    ) async throws -> Bool {

        // Similarity to previous item
        var similarity: SimilarityScore = 0
        if let last = currentItems.last {
            similarity = try await similarityEvaluator.evaluate(
                (last.reasoningContent, candidate.reasoningContent)
            )
        }

        print("Similarity score with last item: \(similarity)")

        if similarity >= 0.90 {
            print("Rejecting reasoning item due to high similarity: \(similarity)")
            return true
        }

        // Model-based redundancy evaluation
        let msgWithCandidate = ConversationMessage(
            role: message.role,
            content: currentItems.map { $0 as any ConversationItem } + [candidate]
        )
        let temp = Conversation(
            with: conversation.session,
            messages: conversation.messages + [msgWithCandidate]
        )

        let r = try await repetitionEvaluator.evaluate(
            (temp, candidate, similarity)
        )

        print("Repetition evaluation result: \(r)")

        return r
    }
}
