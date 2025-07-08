//
//  ReasoningRepetitionEvaluator.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/5/25.
//

import Foundation
import FoundationModels

/// Evaluates whether the provided reasoning item is redundant given the previous conversation history
struct ReasoningRepetitionEvaluator: Evaluator {
    public typealias Input = (Conversation, ConversationReasoningItem, SimilarityScore)
    public typealias Output = Bool

    var instructions: String {
        """
        # System

        You are the **Reasoning Repetition Evaluation Agent**.
        Decide whether the most recent reasoning item is redundant, repeated, incorrect, unclear, or otherwise unnecessary.

        In addition to the conversation history and the new reasoning item, you will be provided with a number representing the similarity of the new reasoning item to the most recent reasoning item in the conversation history. This should help you provide a more accurate evaluation of the reasoning item. The scale of the number is described below:

        - Score = 0.00: No similarity at all.
        - Score > 0.10: The two texts are very different in meaning and content, with little to no overlap.
        - Score > 0.50: The two texts are somewhat similar, sharing some common themes or ideas, but still have significant differences.
        - Score > 0.80: The two texts are quite similar, sharing a lot of common themes or ideas, but may have some differences in wording or structure.
        - Score = 1.00: The two texts are exactly the same, not just in meaning but also in wording and structure.

        ## Evaluation criteria
        * **Coverage** – every sub-question and edge case raised by the user is addressed.
        * **Depth** – each step is logically sound, with no big leaps.
        * **Redundancy** – duplicates count as missing coverage.
        * **Clarity** – a competent assistant could write an excellent answer using only these reasoning items.

        ## What to output
        You should output a single boolean value which indicates whether the new reasoning item is redundant or unnecessary. This will result in the reasoning item being regenerated. **NEVER** mark the first reasoning item in the Assistant's reasoning process as redundant, as this will result in the reasoning process never being completed.

        ## Example Evaluation
        \(PromptExamples.redundancyEvalExample)

        ## Notes
        * If no reasoning items exist yet, return `false`.
        """
    }

    fileprivate func createPrompt(
        for conversation: Conversation, reasoningItem: ConversationReasoningItem,
        similarityScore: SimilarityScore
    ) throws -> String {
        """
        The following is the current conversation history:
        \(conversation.toPlainText())

        The following reasoning item should be evaluated in order to determine whether it is redundant or unnecessary given the conversation history. If you determine it is redundant, it will be regenerated, otherwise it will be added to the conversation history:
        \(reasoningItem.toContext().toPlainText())

        The similarity score of the new reasoning item to the most recent reasoning item in the conversation history is: \(similarityScore)
        """
    }

    func evaluate(_ input: (Conversation, ConversationReasoningItem, SimilarityScore)) async throws
        -> Bool
    {
        let (conversation, reasoningItemToBeAdded, similarityScore) = input
        let filteredConversation = conversation.previousReasoningRemoved()

        let session = LanguageModelSession(instructions: instructions)

        // print("Evaluating reasoning item for redundancy with similarity score: \(similarityScore)")

        let reasoningEvaluationResponse = try await session.respond(
            to: createPrompt(
                for: filteredConversation, reasoningItem: reasoningItemToBeAdded,
                similarityScore: similarityScore),
            generating: Bool.self
        )

        // print("Received reasoning evaluation response: \(reasoningEvaluationResponse.content)")

        return reasoningEvaluationResponse.content
    }
}
