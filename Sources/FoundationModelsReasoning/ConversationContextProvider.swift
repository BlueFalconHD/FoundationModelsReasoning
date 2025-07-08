//
//  ConversationContextProvider.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation

protocol RootConversationContextProvider {
    /// Serialize the context back to prompt-ready text.
    func toPlainText() -> String
}

public typealias ConversationContext = XMLDocument

extension ConversationContext: RootConversationContextProvider {
    public func toPlainText() -> String {
        return xmlString(options: [.nodePrettyPrint])
    }
}

public protocol ConversationContextProvider {
    /// Build an XML document that represents the state you want to feed back
    /// into the model.
    func toContext() -> ConversationContext
}
