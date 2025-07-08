//
//  GenerationOptions+fmrDefaultConfig.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/5/25.
//

import Foundation
import FoundationModels

extension GenerationOptions {
    /// Default configuration for Foundation Models Reasoning.
    public static var fmrDefaultConfig: GenerationOptions {
        GenerationOptions(temperature: Double.random(in: 0.66...0.72))
    }

    /// Reasoning configuration for Foundation Models Reasoning. Has a much shorter max-token limit
    public static var fmrReasoningConfig: GenerationOptions {
        GenerationOptions(
            temperature: 0.74,
            maximumResponseTokens: 400
        )
    }
    
    /// Similarity configuration for Foundation Models Reasoning. Has a much lower temperature
    public static var fmrSimilarityConfig: GenerationOptions {
        GenerationOptions(
            temperature: 0.35,
            maximumResponseTokens: 100
        )
    }
}
