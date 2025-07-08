//
//  ReasoningCompletenessEvaluator.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/5/25.
//

import Foundation
import FoundationModels

@Generable(
    description:
        "Evaluates the reasoning items in a conversation context and " +
        "decides whether the chain-of-thought is complete or needs more work."
)
struct ReasoningCompletenessEvaluation {
    @Guide(
        description:
            "Estimated number of additional reasoning items still required. " +
            "Zero means the reasoning appears complete."
    )
    public var additionalReasoningItemsNeededEstimate: Int

    @Guide(
        description:
            "How many new reasoning items may be generated before this " +
            "evaluator must run again.  MUST NOT exceed the estimate above."
    )
    public var numberOfReasoningItemsUntilNextEvaluation: Int
    
    @Guide(description: "A simple explanation of the reasoning completeness evaluation. It should be extremely concise and to the point. Examples: 'All aspects covered', 'Missing edge cases', 'Needs more depth'.")
    public var explanation: String
}

/// Evaluates the completeness of reasoning in a conversation
struct ReasoningCompletenessEvaluator: Evaluator {
    public typealias Input  = Conversation
    public typealias Output = ReasoningCompletenessEvaluation
    
    var instructions: String {
        """
        # System
        
        You are the **Reasoning Completeness Evaluation Agent**.  
        Decide whether the existing chain-of-thought is complete or needs more work.
        
        ## Evaluation criteria
        * **Coverage** – every sub-question and edge case raised by the user is addressed.
        * **Depth** – each step is logically sound, with no big leaps.
        * **Redundancy** – duplicates count as missing coverage.
        * **Clarity** – a competent assistant could write an excellent answer using only these reasoning items.
        
        ## What to output
        * `additionalReasoningItemsNeededEstimate` – how many *new* non-redundant reasoning steps are still required.
        * `numberOfReasoningItemsUntilNextEvaluation` – how many new steps may be generated before you must be called again (must be <= the estimate above).
        * `explanation` – a simple explanation of the reasoning completeness evaluation. It should be extremely concise and to the point. Examples: "All aspects covered", "Missing edge cases", "Needs more depth". For the first evaluation, you may use "Initial estimate" or "Initial evaluation".
        
        ## Example Evaluation
        \(PromptExamples.additionalEvalExample)
        
        ## Notes
        * If no reasoning items exist yet, give an initial estimate. Since reasoning items are very short (1-3 short sentences), your initial estimate should be somewhere between around 3-7.
        * When uncertain, keep `numberOfReasoningItemsUntilNextEvaluation` small (1-3); choose larger values (4-6) only when the path is clear.
        * DO NOT CONFUSE THE USER'S QUESTION WITH THE REASONING ITEMS.
        """
    }
    
    func evaluate(_ input: Conversation) async throws -> ReasoningCompletenessEvaluation {
        let filteredConversation = input.previousReasoningRemoved()
        let session = LanguageModelSession(instructions: instructions)
        
        let reasoningEvaluationResponse = try await session.respond(
            to: filteredConversation.toPlainText(),
            generating: ReasoningCompletenessEvaluation.self
        )
        
        return reasoningEvaluationResponse.content
    }
}
