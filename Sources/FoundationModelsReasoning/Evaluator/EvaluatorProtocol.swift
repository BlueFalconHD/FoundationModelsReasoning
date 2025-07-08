//
//  EvaluatorProtocol.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/5/25.
//

/// A type-safe evaluator that turns some `Input` value into an `Output` value.
/// Each concrete evaluator chooses its own input/output types.
///
/// If you need to put several different evaluators into the same collection,
/// wrap them with `AnyEvaluator` (see below).
public protocol Evaluator {
    associatedtype Input
    associatedtype Output

    /// The prompt / system instructions that guide the model.
    var instructions: String { get }

    /// Run the evaluation.
    func evaluate(_ input: Input) async throws -> Output
}

/// A type-erased wrapper so you can keep heterogeneous evaluators in an array,
/// dictionary, etc.  The concrete types of `Input`/`Output` are hidden.
public struct AnyEvaluator<I, O>: Evaluator {
    public typealias Input = I
    public typealias Output = O

    private let _instructions: () -> String
    private let _evaluate: (I) async throws -> O

    public init<E: Evaluator>(_ evaluator: E) where E.Input == I, E.Output == O {
        _instructions = { evaluator.instructions }
        _evaluate = evaluator.evaluate
    }

    public var instructions: String { _instructions() }

    public func evaluate(_ input: I) async throws -> O {
        try await _evaluate(input)
    }
}

/// Error type for evaluation failures.
enum EvaluationError: Error {
    case invalidInput(String)
}
