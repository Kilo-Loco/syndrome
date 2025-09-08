import Foundation

/// Represents a block-level element in a Markdown document.
///
/// Block elements are the primary structural components of a Markdown document,
/// such as headings, paragraphs, and lists. They form the top-level structure
/// and cannot be nested within inline elements.
///
/// ## Hierarchy
///
/// Block elements may contain:
/// - Inline elements (in paragraphs, headings, list items)
/// - Other block elements (in blockquotes, list items)
///
/// ## Usage Example
///
/// ```swift
/// let document = MarkdownParser.parse("# Title\n\nParagraph")
///
/// for block in document.blocks {
///     switch block {
///     case .heading(let level, let content):
///         print("Heading level \(level)")
///     case .paragraph(let content):
///         print("Paragraph with \(content.count) inline elements")
///     default:
///         break
///     }
/// }
/// ```
///
/// - Since: 1.0.0
@frozen
public enum BlockElement: MarkdownElement {
    /// A heading element with a level (1-6) and inline content.
    ///
    /// Corresponds to HTML `<h1>` through `<h6>` elements.
    ///
    /// - Parameters:
    ///   - level: The heading level, from 1 (largest) to 6 (smallest).
    ///            Values outside 1-6 indicate parser errors.
    ///   - content: The inline elements that make up the heading text.
    ///
    /// ## Example
    /// ```swift
    /// case .heading(level: 2, content: [.text("Section Title")])
    /// // Represents: ## Section Title
    /// ```
    case heading(level: Int, content: [InlineElement])
    
    /// A paragraph containing inline elements.
    ///
    /// Paragraphs are the most common block element, containing
    /// text and inline formatting.
    ///
    /// - Parameter content: Array of inline elements forming the paragraph.
    ///
    /// ## Example
    /// ```swift
    /// case .paragraph(content: [
    ///     .text("Hello "),
    ///     .strongEmphasis(content: [.text("world")]),
    ///     .text("!")
    /// ])
    /// // Represents: Hello **world**!
    /// ```
    case paragraph(content: [InlineElement])
    
    /// A fenced code block with optional language identifier.
    ///
    /// Code blocks preserve formatting and do not process inline elements.
    /// HTML entities and escape sequences are not processed in code blocks.
    ///
    /// - Parameters:
    ///   - info: Optional language identifier or info string (e.g., "swift", "json").
    ///   - content: The literal code content, with leading/trailing newlines trimmed.
    ///
    /// ## Example
    /// ```swift
    /// case .codeBlock(info: "swift", content: "let x = 42")
    /// // Represents: ```swift
    /// //            let x = 42
    /// //            ```
    /// ```
    case codeBlock(info: String?, content: String)
    
    /// A list containing multiple items.
    ///
    /// Lists can be ordered (numbered) or unordered (bulleted).
    /// Each item may contain multiple block elements.
    ///
    /// - Parameters:
    ///   - items: Array of list items.
    ///   - type: The list type (ordered or unordered).
    ///
    /// ## Example
    /// ```swift
    /// case .list(
    ///     items: [
    ///         ListItem(content: [.paragraph(content: [.text("First")])], tight: true),
    ///         ListItem(content: [.paragraph(content: [.text("Second")])], tight: true)
    ///     ],
    ///     type: .unordered(marker: "-")
    /// )
    /// // Represents: - First
    /// //            - Second
    /// ```
    case list(items: [ListItem], type: ListType)
    
    /// A blockquote containing other block elements.
    ///
    /// Blockquotes can be nested and may contain any block element,
    /// including other blockquotes.
    ///
    /// - Parameter content: Array of block elements within the blockquote.
    ///
    /// ## Example
    /// ```swift
    /// case .blockquote(content: [
    ///     .paragraph(content: [.text("Quoted text")])
    /// ])
    /// // Represents: > Quoted text
    /// ```
    case blockquote(content: [BlockElement])
    
    /// A horizontal rule (thematic break).
    ///
    /// Represents a thematic break between sections.
    /// Typically renders as a horizontal line.
    ///
    /// ## Example
    /// ```swift
    /// case .horizontalRule
    /// // Represents: --- or *** or ___
    /// ```
    case horizontalRule
    
    /// A raw HTML block.
    ///
    /// Contains literal HTML that should be passed through unchanged.
    ///
    /// - Parameter content: The raw HTML content.
    ///
    /// - Warning: HTML blocks are not sanitized. Be cautious when
    ///           rendering user-provided Markdown containing HTML.
    ///
    /// ## Example
    /// ```swift
    /// case .htmlBlock(content: "<div>Custom HTML</div>")
    /// ```
    case htmlBlock(content: String)
    
    /// The element type identifier for protocol conformance.
    public var elementType: MarkdownElementType { .block }
}