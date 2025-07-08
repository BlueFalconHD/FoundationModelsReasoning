//
//  GeneratorProtocol.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/7/25.
//

import Foundation
import FoundationModels

/// Generates an `Output` given some `Input`.
/// Made for true model output rather than evaluation.
public protocol Generator {
    associatedtype Input
    associatedtype Output: ConversationItem, Generable

    /// System instructions that prime the model.
    var instructions: String { get }

    /// Produce an `Output` from `input` using the provided session.
    /// The returned `ResponseStream` yields partial tokens as they are
    /// produced by the model and can be `collect()`-ed to obtain the
    /// finished `Output` value.
    func generate(from input: Input) async throws -> LanguageModelSession.ResponseStream<Output>
    where Output: Generable
}
