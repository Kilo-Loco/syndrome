import Foundation

/// Represents an inline element within a Markdown block.
///
/// Inline elements provide formatting and structure within block-level elements
/// like paragraphs and headings. They can be nested to create complex formatting.
///
/// ## Nesting
///
/// Inline elements can contain other inline elements, allowing for
/// combinations like bold italic text or links with formatted text.
///
/// ## Usage Example
///
/// ```swift
/// let paragraph = BlockElement.paragraph(content: [
///     .text("Visit "),
///     .link(
///         text: [.strongEmphasis(content: [.text("our site")])],
///         url: "https://example.com",
///         title: "Homepage"
///     ),
///     .text(" for more.")
/// ])
/// // Represents: Visit [**our site**](https://example.com "Homepage") for more.
/// ```
///
/// - Since: 1.0.0
@frozen
public enum InlineElement: MarkdownElement {
    /// Plain text content.
    ///
    /// Represents unformatted text within a block element.
    /// Special characters should already be processed (entities decoded, escapes handled).
    ///
    /// - Parameter text: The literal text content.
    ///
    /// ## Example
    /// ```swift
    /// case .text("Hello, world!")
    /// ```
    case text(String)
    
    /// Emphasized (italic) text.
    ///
    /// Typically renders as italic text. Can be created with single
    /// asterisks (*text*) or underscores (_text_).
    ///
    /// - Parameter content: Array of inline elements within the emphasis.
    ///
    /// ## Example
    /// ```swift
    /// case .emphasis(content: [.text("important")])
    /// // Represents: *important* or _important_
    /// ```
    case emphasis(content: [InlineElement])
    
    /// Strongly emphasized (bold) text.
    ///
    /// Typically renders as bold text. Can be created with double
    /// asterisks (**text**) or underscores (__text__).
    ///
    /// - Parameter content: Array of inline elements within the strong emphasis.
    ///
    /// ## Example
    /// ```swift
    /// case .strongEmphasis(content: [.text("very important")])
    /// // Represents: **very important** or __very important__
    /// ```
    case strongEmphasis(content: [InlineElement])
    
    /// Inline code span.
    ///
    /// Represents code within a paragraph or heading. Content is treated
    /// as literal text - no inline processing occurs within code spans.
    ///
    /// - Parameter code: The literal code text.
    ///
    /// ## Example
    /// ```swift
    /// case .code("let x = 42")
    /// // Represents: `let x = 42`
    /// ```
    ///
    /// - Note: HTML entities and escape sequences are not processed in code spans.
    case code(String)
    
    /// A hyperlink with text and destination.
    ///
    /// Links can contain formatted text and have an optional title attribute.
    ///
    /// - Parameters:
    ///   - text: Array of inline elements forming the link text.
    ///   - url: The link destination URL (can be relative or absolute).
    ///   - title: Optional title attribute for the link.
    ///
    /// ## Example
    /// ```swift
    /// case .link(
    ///     text: [.text("GitHub")],
    ///     url: "https://github.com",
    ///     title: "Visit GitHub"
    /// )
    /// // Represents: [GitHub](https://github.com "Visit GitHub")
    /// ```
    case link(text: [InlineElement], url: String, title: String?)
    
    /// An inline image.
    ///
    /// Images have alt text (for accessibility), a source URL, and optional title.
    ///
    /// - Parameters:
    ///   - alt: Array of inline elements forming the alt text.
    ///   - url: The image source URL (can be relative or absolute).
    ///   - title: Optional title attribute for the image.
    ///
    /// ## Example
    /// ```swift
    /// case .image(
    ///     alt: [.text("Logo")],
    ///     url: "logo.png",
    ///     title: "Company Logo"
    /// )
    /// // Represents: ![Logo](logo.png "Company Logo")
    /// ```
    case image(alt: [InlineElement], url: String, title: String?)
    
    /// Raw inline HTML.
    ///
    /// Contains literal HTML that should be passed through unchanged.
    ///
    /// - Parameter content: The raw HTML content.
    ///
    /// - Warning: Inline HTML is not sanitized. Be cautious when
    ///           rendering user-provided Markdown containing HTML.
    ///
    /// ## Example
    /// ```swift
    /// case .htmlInline(content: "<span class=\"custom\">text</span>")
    /// ```
    case htmlInline(content: String)
    
    /// A soft line break within a paragraph.
    ///
    /// Represents a newline in the source that should typically
    /// render as a space in the output.
    ///
    /// ## Example
    /// ```swift
    /// // "Line one\nLine two" produces:
    /// [.text("Line one"), .softBreak, .text("Line two")]
    /// ```
    case softBreak
    
    /// A hard line break within a paragraph.
    ///
    /// Represents an explicit line break (created with two spaces before newline
    /// or a backslash before newline). Should render as an actual line break.
    ///
    /// ## Example
    /// ```swift
    /// // "Line one  \nLine two" produces:
    /// [.text("Line one"), .hardBreak, .text("Line two")]
    /// ```
    case hardBreak
    
    /// The element type identifier for protocol conformance.
    public var elementType: MarkdownElementType { .inline }
}