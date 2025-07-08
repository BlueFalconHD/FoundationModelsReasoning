//
//  ConversationRole.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation
import FoundationModels

/// Represents the role of a message in a conversation.
public enum ConversationRole: String, Codable, CaseIterable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
}
