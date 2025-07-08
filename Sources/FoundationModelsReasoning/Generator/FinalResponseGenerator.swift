//
//  FinalResponseGenerator.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/7/25.
//

import Foundation
import FoundationModels

/// Generates a final response from the model based on the conversation context.
struct FinalResponseGenerator: Generator {
    typealias Input = Conversation
    typealias Output = ConversationPlainTextItem
    
    var instructions: String {
            """
            # System
            
            You are the **assistant**.
            The user will read everything you write here.
            
            ## Task
            Read the entire conversation context—including every `ReasoningItem`—and
            produce a single, coherent answer to the user’s original question.
            
            ## Guidelines
            * Summarise and integrate the insights from all reasoning steps.
            * If the solution involves calculations or logic, show the key steps succinctly (1–5 lines), then state the answer plainly.
            * Be concise yet complete; prefer short paragraphs or bullet lists where that improves readability.
            * Refer only to your reasoning, don't respond on the fly without referencing them.
            
            ## Example final response
            \(PromptExamples.responseExample)
            """
    }
    
    func generate(from input: Conversation) async throws -> LanguageModelSession.ResponseStream<ConversationPlainTextItem> {
        let session = LanguageModelSession(instructions: instructions)
        
        let response = session.streamResponse(
            to: input.toPlainText(), generating: ConversationPlainTextItem.self,
            options: .fmrDefaultConfig)
        
        return response
    }
}


