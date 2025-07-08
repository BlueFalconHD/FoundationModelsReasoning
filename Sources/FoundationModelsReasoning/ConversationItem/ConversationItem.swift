//
//  ConversationItem.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation
import FoundationModels

/// Represents a type which can be used in the body of a conversation message.
/// It must conform to `ConversationContextProvider` to provide context for further messages.
public protocol ConversationItem: ConversationContextProvider {}
