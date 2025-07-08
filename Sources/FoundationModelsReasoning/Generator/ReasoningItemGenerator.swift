//
//  ReasoningItemGenerator.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/7/25.
//

import Foundation
import FoundationModels

struct ReasoningItemGenerator: Generator {
    typealias Input = Conversation  // important: the conversation must also include the current message being generated (eg Conversation(with: ..., messages: conversation.messages + [newMessage]))
    typealias Output = ConversationReasoningItem

    /// Titles of all reasoning items that already exist in the conversation.
    /// This is fed back into the prompt to avoid duplication.
    fileprivate func existingReasoningTitles(in conversation: Conversation) -> [String] {
        conversation.messages
            .flatMap { $0.content }
            .compactMap { $0 as? ConversationReasoningItem }
            .map(\.title)
    }

    fileprivate func createInstructions(with coveredTitles: [String]) -> String {
        return """
            # System

            You are an **internal chain-of-thought agent**.
            The user never sees what you write here.

            ## Goal
            Plan a complete, ordered set of reasoning steps that will let a downstream assistant craft the best possible final answer.

            ## Guidelines
            * Think step-by-step; each reasoning item must add new, non-redundant value.
            * Do **not** answer the user or mention this reasoning process.
            * Skim previous `ReasoningItem`s first and avoid repeating them. I repeat, **do not repeat reasoning items**.
            * **IMPORTANT**: End every `reasoningContent` with `Self-check: <brief verification of this step>` along with justification for why this reasoning step isn't redundant.
            * Each reasoning item should be very short, ideally 1–3 sentences. It is better to have more short items than fewer long ones.
            * Set `evalNeeded` to **true** only when you are confident the plan is fully fleshed out.

            ## Already covered
            These are the titles of previously covered reasoning items. You should not repeat the same titles, think of new original ones for each step.
            \(coveredTitles.isEmpty
            ? "- (no prior reasoning items)"
            : coveredTitles.map { "* \($0)" }.joined(separator: "\n"))

            ## Example reasoning steps
            \(PromptExamples.reasoningExample)
            """
    }

    var instructions: String {
        createInstructions(with: [])
    }

    func generate(from input: Conversation) async throws
        -> LanguageModelSession.ResponseStream<Output>
    {
        let coveredTitles = existingReasoningTitles(in: input)
        let session = LanguageModelSession(instructions: createInstructions(with: coveredTitles))

        let reasoningItemResponse = session.streamResponse(
            to: input.toPlainText(), generating: ConversationReasoningItem.self,
            options: .fmrReasoningConfig)

        return reasoningItemResponse
    }
}
