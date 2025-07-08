//
//  ConversationReasoningItem.swift
//  FoundationModelsReasoning
//
//  Created by Hayes Dombroski on 7/4/25.
//

import Foundation
import FoundationModels

/// Represents a reasoning item in a conversation, which includes a title and reasoning content.
/// Reasoning items are used to provide detailed explanations or justifications for certain decisions or responses within a conversation.

// Can't use @Generable because of issues with `id` not being public
//@Generable(
//    description:
//        "A reasoning item in a conversation, containing content (your thinking process) and a title (short summary of the content digestable in an interface)."
//)
// Uncomment and use Xcode's expand macro feature if you want to easily edit the schema in the future.

public struct ConversationReasoningItem: ConversationItem, Sendable {
    @Guide(
        description:
            "The content of the reasoning item, which is your thinking process or explanation.")
    public var reasoningContent: String

    @Guide(description: "A short summary of the reasoning content, digestible in an interface.")
    public var title: String

    @Guide(
        description:
            "Indicates whether another evaluation of the reasoning process, which determiness whether the reasoning should continue, is needed. You should not set this flag unless you fully believe you should be done with your reasoning process, and even then the evaluation might determine further reasoning is necessary."
    )
    public var evalNeeded: Bool

    // BEGIN XCODE MACRO EXPANSION INLINING
    nonisolated public static var generationSchema: FoundationModels.GenerationSchema {
        FoundationModels.GenerationSchema(
            type: Self.self,
            description:
                "A reasoning item in a conversation, containing content (your thinking process) and a title (short summary of the content digestable in an interface).",
            properties: [
                FoundationModels.GenerationSchema.Property(
                    name: "reasoningContent",
                    description:
                        "The content of the reasoning item, which is your thinking process or explanation.",
                    type: String.self),
                FoundationModels.GenerationSchema.Property(
                    name: "title",
                    description:
                        "A short summary of the reasoning content, digestible in an interface.",
                    type: String.self),
                FoundationModels.GenerationSchema.Property(
                    name: "evalNeeded",
                    description:
                        "Indicates whether another evaluation of the reasoning process, which determiness whether the reasoning should continue, is needed. You should not set this flag unless you fully believe you should be done with your reasoning process, and even then the evaluation might determine further reasoning is necessary.",
                    type: Bool.self),
            ]
        )
    }

    nonisolated public var generatedContent: GeneratedContent {
        GeneratedContent(
            properties: [
                "reasoningContent": reasoningContent,
                "title": title,
                "evalNeeded": evalNeeded,
            ]
        )
    }

    nonisolated public struct PartiallyGenerated: Identifiable, ConvertibleFromGeneratedContent,
        Sendable, Equatable, Hashable
    {
        public var id: GenerationID
        public var reasoningContent: String.PartiallyGenerated?
        public var title: String.PartiallyGenerated?
        public var evalNeeded: Bool.PartiallyGenerated?
        nonisolated public init(_ content: FoundationModels.GeneratedContent) throws {
            self.id = content.id ?? GenerationID()
            self.reasoningContent = try content.value(forProperty: "reasoningContent")
            self.title = try content.value(forProperty: "title")
            self.evalNeeded = try content.value(forProperty: "evalNeeded")
        }
    }

    // END XCODE MACRO EXPANSION INLINING
}

// BEGIN XCODE MACRO EXPANSION INLINING

extension ConversationReasoningItem: FoundationModels.Generable {
    nonisolated public init(_ content: FoundationModels.GeneratedContent) throws {
        self.reasoningContent = try content.value(forProperty: "reasoningContent")
        self.title = try content.value(forProperty: "title")
        self.evalNeeded = try content.value(forProperty: "evalNeeded")
    }
}

// END XCODE MACRO EXPANSION INLINING

extension ConversationReasoningItem: ConversationContextProvider {
    public func toContext() -> ConversationContext {
        // <ReasoningItem title="${title}">
        //     ${reasoningContent}
        // </ReasoningItem>

        let root = XMLElement(name: "ReasoningItem")
        root.addAttribute(XMLNode.attribute(withName: "title", stringValue: title) as! XMLNode)
        root.stringValue = reasoningContent

        return ConversationContext(rootElement: root)
    }
}
