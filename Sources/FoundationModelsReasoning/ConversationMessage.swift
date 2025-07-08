//
//  ConversationMessage.swift
//  FoundationModelsReasoning
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation
import FoundationModels

public class ConversationMessage: ConversationContextProvider, @unchecked Sendable {
    let role: ConversationRole
    var content: [any ConversationItem]

    private let reasoningOrchestrator = ReasoningOrchestrator()
    private let finalResponseGenerator = FinalResponseGenerator()

    // MARK: - Streaming

    /// Events that can be emitted while the assistant message is being
    /// generated. Render them incrementally in a SwiftUI view.
    enum StreamEvent {
        /// Snapshot of all reasoning items generated so far.
        /// The list may contain unfinished (`PartiallyGenerated`) items.
        case reasoning([ConversationReasoningItem.PartiallyGenerated])

        /// A partially-generated (or finished) visible answer for the user.
        case final(ConversationPlainTextItem.PartiallyGenerated)
    }

    /// Initializes a new conversation message with a role and no content.
    public init(role: ConversationRole, content: [any ConversationItem] = []) {
        self.role = role
        self.content = content
    }

    /// Generates the assistant's reply **while streaming partial results**.
    /// - Returns: An `AsyncThrowingStream` that yields `StreamEvent`s which
    ///            the UI can subscribe to for live updates.
    func generate(
        using conversation: Conversation,
        with session: LanguageModelSession
    ) -> AsyncThrowingStream<StreamEvent, Error> {

        AsyncThrowingStream { continuation in
            Task {
                do {
                    // 1️⃣  STREAM REASONING ITEMS
                    for try await snapshot in reasoningOrchestrator.reason(
                        for: self,
                        in: conversation
                    ) {
                        continuation.yield(.reasoning(snapshot))
                    }

                    // Persist completed reasoning items.
                    let finalizedReasoning = await reasoningOrchestrator.finalItems
                    self.content = finalizedReasoning.map { $0 as any ConversationItem }

                    // 2️⃣  STREAM FINAL VISIBLE ANSWER
                    let messageWithContent = ConversationMessage(role: role, content: content)
                    let tempConversation = Conversation(
                        with: conversation.session,
                        messages: conversation.messages + [messageWithContent]
                    )

                    let responseStream = try await finalResponseGenerator.generate(
                        from: tempConversation
                    )

                    for try await partial in responseStream {
                        continuation.yield(.final(partial))
                    }

                    // Collect fully-formed answer and store it.
                    let fullAnswer = try await responseStream.collect().content
                    self.content.append(fullAnswer)

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Transforms the message into a conversation context.
    public func toContext() -> ConversationContext {
        // <Message role="${role.rawValue}">
        //   ${for item in content}
        // </Message>
        let root = XMLElement(name: "Message")
        root.addAttribute(
            XMLNode.attribute(withName: "role", stringValue: role.rawValue) as! XMLNode)
        for item in content {
            let context = item.toContext()
            if let element = context.rootElement()?.copy() as? XMLNode {
                root.addChild(element)
            }
        }

        return ConversationContext(rootElement: root)
    }

    private func wrappedAndIndented(
        _ text: String,
        indent: String = "    ",
        lineLength: Int = 80
    ) -> String {

        let paragraphs = text.split(
            separator: "\n",
            omittingEmptySubsequences: false
        )

        var outputLines: [String] = []

        for paragraph in paragraphs {
            guard !paragraph.isEmpty else {
                outputLines.append(indent)
                continue
            }

            var currentLine = ""
            for word in paragraph.split(separator: " ") {
                if (currentLine.count + word.count + 1) > lineLength {
                    outputLines.append(indent + currentLine)
                    currentLine = String(word)
                } else {
                    if currentLine.isEmpty {
                        currentLine = String(word)
                    } else {
                        currentLine += " " + word
                    }
                }
            }

            if !currentLine.isEmpty {
                outputLines.append(indent + currentLine)
            }
        }

        return outputLines.joined(separator: "\n")
    }

}

extension ConversationMessage: RootConversationContextProvider {
    public func toPlainText() -> String {
        // turn the xml document into a plain text representation
        return toContext().toPlainText()
    }
}
