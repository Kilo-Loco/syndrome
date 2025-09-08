import Foundation

/// A protocol that all Markdown elements conform to.
///
/// This protocol provides a common interface for all Markdown elements,
/// allowing them to be categorized and processed uniformly.
///
/// ## Conforming Types
///
/// The following types conform to `MarkdownElement`:
/// - `BlockElement`: Block-level elements like headings and paragraphs
/// - `InlineElement`: Inline elements like emphasis and links
///
/// ## Usage Example
///
/// ```swift
/// func processElement(_ element: MarkdownElement) {
///     switch element.elementType {
///     case .block:
///         print("Processing block element")
///     case .inline:
///         print("Processing inline element")
///     case .container:
///         print("Processing container element")
///     }
/// }
/// ```
///
/// - Since: 1.0.0
public protocol MarkdownElement {
    /// The type category of this Markdown element.
    ///
    /// Used to identify whether an element is block-level, inline,
    /// or a container type for processing and rendering decisions.
    var elementType: MarkdownElementType { get }
}

/// Categorizes Markdown elements by their structural role.
///
/// This enumeration helps distinguish between different types of
/// Markdown elements for processing and rendering.
///
/// ## Categories
///
/// - **Block**: Structural elements that form the document outline
/// - **Inline**: Formatting elements within blocks
/// - **Container**: Elements that can contain other elements (reserved for future use)
///
/// - Since: 1.0.0
public enum MarkdownElementType {
    /// Block-level elements that form document structure.
    ///
    /// Examples: headings, paragraphs, lists, code blocks, blockquotes
    case block
    
    /// Inline elements that provide formatting within blocks.
    ///
    /// Examples: emphasis, links, code spans, line breaks
    case inline
    
    /// Container elements that can hold other elements.
    ///
    /// - Note: Currently unused. Reserved for future extensions
    ///         like table cells or custom containers.
    case container
}