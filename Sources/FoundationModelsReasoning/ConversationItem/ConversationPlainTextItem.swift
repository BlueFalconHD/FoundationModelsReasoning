//
//  ConversationPlainTextItem.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation
import FoundationModels

/// Represents a plain text item in a message within a conversation.
/// There should only be one `ConversationPlainTextItem` at the end of a `ConversationMessage`.

// Can't use @Generable because of issues with `id` not being public
//@Generable(
//    description:
//        "A plain text item in a conversation message which contains your final response to be shown to the user."
//)
// Uncomment and use Xcode's expand macro feature if you want to easily edit the schema in the future.
public struct ConversationPlainTextItem: ConversationItem {
    @Guide(
        description:
            "The text content of the plain text item, which is your final response to be shown to the user."
    )
    public var text: String

    // BEGIN XCODE MACRO EXPANSION INLINING
    nonisolated public static var generationSchema: FoundationModels.GenerationSchema {
        FoundationModels.GenerationSchema(
            type: Self.self,
            description:
                "A plain text item in a conversation message which contains your final response to be shown to the user.",
            properties: [
                FoundationModels.GenerationSchema.Property(
                    name: "text",
                    description:
                        "The text content of the plain text item, which is your final response to be shown to the user.",
                    type: String.self)
            ]
        )
    }

    nonisolated public var generatedContent: GeneratedContent {
        GeneratedContent(
            properties: [
                "text": text
            ]
        )
    }

    nonisolated public struct PartiallyGenerated: Identifiable, ConvertibleFromGeneratedContent,
        Sendable
    {
        public var id: GenerationID
        var text: String.PartiallyGenerated?
        nonisolated public init(_ content: FoundationModels.GeneratedContent) throws {
            self.id = content.id ?? GenerationID()
            self.text = try content.value(forProperty: "text")
        }
    }
    // END XCODE MACRO EXPANSION INLINING

    // initializer for the struct
    public init(text: String) {
        self.text = text
    }
}

// BEGIN XCODE MACRO EXPANSION INLINING
extension ConversationPlainTextItem: FoundationModels.Generable {
    nonisolated public init(_ content: FoundationModels.GeneratedContent) throws {
        self.text = try content.value(forProperty: "text")
    }
}
// END XCODE MACRO EXPANSION INLINING

extension ConversationPlainTextItem: ConversationContextProvider {
    public func toContext() -> ConversationContext {
        // <text>${text}</text>
        let root = XMLElement(name: "text")
        root.stringValue = text
        return ConversationContext(rootElement: root)
    }
}
