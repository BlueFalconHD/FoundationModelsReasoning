//
//  SimilarityEvaluator.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/5/25.
//

import Foundation
import FoundationModels

public typealias SimilarityScore = Double

/// This evaluator compares two pieces of text and evaluates their similarity in meaning and content.
struct SimilarityEvaluator: Evaluator {
    typealias Input  = (String, String)   // a tuple ← clear & concise
    typealias Output = SimilarityScore
    
    internal var instructions: String {
        """
        # System
        You are the **similarity evaluation agent**. Your task is to evaluate the similarity between two pieces of text to determine how closely they match in meaning and content. You will output a similarity score between 0 and 1, where 0 means no similarity and 1 means **exactly** identical content.
        
        ## Similarity Score
        Your score should be a number between 0 and 1, here is a sort of map of what the scores mean. Your score should not exactly match these numbers, however it should be in the same range and follow the same general meaning:
        
        - Score = 0.00: No similarity at all.
        - Score > 0.10: The two texts are very different in meaning and content, with little to no overlap.
        - Score > 0.50: The two texts are somewhat similar, sharing some common themes or ideas, but still have significant differences.
        - Score > 0.80: The two texts are quite similar, sharing a lot of common themes or ideas, but may have some differences in wording or structure.
        - Score = 1.00: The two texts are exactly the same, not just in meaning but also in wording and structure.
        
        ## Similarity Criteria
        Some text may seem similar (e.g. share some common parts) but not be similar in meaning or purpose. When evaluating similarity, consider the following criteria:
        - **Meaning**: Do the texts convey the same or similar ideas?
        - **Content**: Do the texts cover the same topics or themes?
        
        For texts including mathematics or logic/reasoning, if the final result of an expression in the first text is used in the second text, the similarity score should not be high because the semantic meaning of the two texts is different, even if they share some common parts.
        
        
        ## Examples
        Text A: "Paris is the capital of France."
        Text B: "France's capital city is Paris."
        Similarity Score: 0.95

        Text A: "Cats are mammals."
        Text B: "The integral of x^2 is x^3/3."
        Similarity Score: 0.02
        
        Text A: "The quick brown fox jumps over the lazy dog."
        Text B: "A completely unrelated sentence that has no similarity to the first."
        Similarity Score: 0.00
        
        Text A: "16 + 4 = 20"
        Text B: "The sum of 16 and 4 is 20."
        Similarity Score: 0.85
        
        Text A: "Ava's fruit is an apple because she brought it on Monday."
        Text B: "The fruit that Ava brought on Monday is an apple."
        Similarity Score: 0.84
        
        ## Output Format
        Output a single number between 0 and 1, representing the similarity score.
        """
    }
    
    func evaluate(_ input: Input) async throws -> Output {
        let (a, b) = input

        let prompt = """
        Evaluate the similarity between the following two texts:

        Text A: \(a)

        Text B: \(b)
        """

        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(
            to: prompt,
            generating: SimilarityScore.self,
            options: .fmrSimilarityConfig
        )
        return response.content
    }
}
