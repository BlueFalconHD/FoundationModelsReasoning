import Foundation
import FoundationModels
import Testing

@testable import FoundationModelsReasoning

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let sess = LanguageModelSession()
    let conversation = Conversation(with: sess)

    let message = ConversationMessage(role: .user)
    message.content.append(
        ConversationPlainTextItem(text: "I leave work at 1:15 p.m. The bus ride to the train station takes 35 minutes. My train boards 15 minutes before its 2:30 p.m. departure, and the ticket check normally takes 10 minutes. Will I catch the train on time? Please explain your reasoning."))
    conversation.addMessage(message)

    // Stream the response
    let stream = conversation.generateMessage()

    var finalResponse: String?
    var reasoningSteps: [String] = []

    for try await event in stream {
        switch event {
        case .reasoning(let items):
            // Capture the latest reasoning snapshot
            reasoningSteps = items.map { item in
                "[\(item.title ?? "...")]: \(item.reasoningContent ?? "...")"
            }
            if let lastStep = reasoningSteps.last {
                print("Latest reasoning step: \(lastStep.prefix(50))...")
            }

        case .final(let partial):
            // Update with latest partial response
            finalResponse = partial.text
            if let text = partial.text {
                print("Partial response: \(text.prefix(50))...")
            }
        }
    }

    // Print final results
    print("\n=== Final Results ===")
    print("Reasoning steps (\(reasoningSteps.count)):")
    for step in reasoningSteps {
        print("  • \(step)")
    }
    print("\nFinal response:")
    print(finalResponse ?? "No response generated")

    // Verify we got a response
    #expect(finalResponse != nil, "Expected a final response to be generated")
    #expect(!reasoningSteps.isEmpty, "Expected at least one reasoning step")
}

@Test func similarityEvaluatorExactMatchingText() async throws {
    let seval = SimilarityEvaluator()

    let testString =
        "To evaluate if the user catches the train on time, we first determine their arrival time at the train station. Leaving work at 1:15 p.m., and taking a 35-minute bus ride, the user arrives at the bus stop by 1:50 p.m. Adding the boarding time for the train, which is 15 minutes before its 2:30 p.m. departure, boarding begins at 2:15 p.m. Including the 10-minute ticket check, boarding concludes by 2:25 p.m. Boarding ends before the train departs at 2:30 p.m., ensuring the user catches the train."

    for _ in 0..<10 {
        let similarityScore = try await seval.evaluate((testString, testString))
        #expect(
            similarityScore == 1.0,
            "Expected similarity score to be 1.0 for exact matching text, got \(similarityScore)")
    }
}

@Test func similarityEvaluatorCompletelyDifferentText() async throws {
    let seval = SimilarityEvaluator()

    let testStringA = "The quick brown fox jumps over the lazy dog."
    let testStringB = "A completely unrelated sentence that has no similarity to the first."

    var rollingAverageSimilarity: SimilarityScore = 0.0

    for _ in 0..<10 {
        let similarityScore = try await seval.evaluate((testStringA, testStringB))
        rollingAverageSimilarity += similarityScore
        #expect(
            similarityScore == 0.0,
            "Expected similarity score to be 0.0 for completely different text, got \(similarityScore)"
        )
    }

    rollingAverageSimilarity /= 10.0
    print("Average similarity score for completely different text: \(rollingAverageSimilarity)")
}

@Test func similarityEvaluatorVerySimilarText() async throws {
    let seval = SimilarityEvaluator()

    let testStringA =
        "To confirm whether the user will catch the train on time, we first calculate their arrival time at the train station. Starting from leaving work at 1:15 p.m., a 35-minute bus ride takes them to the bus stop by 1:50 p.m. Adding the train boarding time, 15 minutes before the 2:30 p.m. departure, boarding begins at 2:15 p.m. Including a 10-minute ticket check, boarding ends by 2:25 p.m. Since boarding concludes before the train departs at 2:30 p.m., the user catches the train."

    let testStringB =
        "To determine if the user catches the train on time, we first need to calculate their arrival time at the train station. Since the user leaves work at 1:15 p.m., and the bus ride takes 35 minutes, they will arrive at the bus stop by 1:50 p.m. Next, we add the train boarding time, which is 15 minutes before the 2:30 p.m. departure. This means boarding starts at 2:15 p.m. Adding the 10-minute ticket check time, the user will finish boarding and checking tickets by 2:25 p.m."

    var rollingAverageSimilarity: SimilarityScore = 0.0

    for _ in 0..<10 {
        let similarityScore = try await seval.evaluate((testStringA, testStringB))
        rollingAverageSimilarity += similarityScore
    }

    rollingAverageSimilarity /= 10.0
    print("Average similarity score for very similar text: \(rollingAverageSimilarity)")
    #expect(
        rollingAverageSimilarity > 0.8,
        "Expected similarity score to be greater than 0.8 for very similar text, got \(rollingAverageSimilarity)"
    )
}
