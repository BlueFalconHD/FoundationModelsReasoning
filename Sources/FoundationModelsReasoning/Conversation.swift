//
//  Conversation.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation
import FoundationModels

public class Conversation: ConversationContextProvider, @unchecked Sendable {
    public let session: LanguageModelSession
    public var messages: [ConversationMessage]

    public init(with session: LanguageModelSession, messages: [ConversationMessage] = []) {
        self.session = session
        self.messages = messages
    }

    /// Adds a message to the conversation.
    public func addMessage(_ message: ConversationMessage) {
        messages.append(message)
    }

    /// Generates a new assistant message and **streams** partial output.
    /// Forward the returned stream to your SwiftUI `View` for live rendering.
    public func generateMessage()
        -> AsyncThrowingStream<ConversationMessage.StreamEvent, Error>
    {
        let newMessage = ConversationMessage(role: .assistant, content: [])
        addMessage(newMessage)
        return newMessage.generate(using: self, with: session)
    }

    /// Transforms the conversation into a context representation.
    public func toContext() -> ConversationContext {
        let root = XMLElement(name: "Conversation")
        for message in messages {
            let context = message.toContext()
            if let element = context.rootElement()?.copy() as? XMLNode {
                root.addChild(element)
            }
        }
        return ConversationContext(rootElement: root)
    }

    /// Returns a new conversation with reasoning items removed from all but the last message.
    public func previousReasoningRemoved() -> Conversation {
        guard !messages.isEmpty else { return self }
        let lastIndex = messages.count - 1
        let filteredMessages = messages.enumerated().map { idx, message in
            if idx == lastIndex {
                // Keep the last message as is
                return message
            } else {
                let newContent = message.content.filter { $0 is ConversationPlainTextItem }
                return ConversationMessage(role: message.role, content: newContent)
            }
        }
        return Conversation(with: session, messages: filteredMessages)
    }
}

extension Conversation: RootConversationContextProvider {
    /// Serializes the conversation to a plain text representation.
    public func toPlainText() -> String {
        return toContext().toPlainText()
    }
}
