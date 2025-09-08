import Foundation

/// Specifies the type and formatting of a Markdown list.
///
/// Lists can be either ordered (numbered) or unordered (bulleted),
/// with various marker and delimiter styles.
///
/// ## Example
///
/// ```swift
/// // Unordered list with dash marker
/// let bulletList = ListType.unordered(marker: "-")
///
/// // Ordered list starting at 1 with period delimiter
/// let numberedList = ListType.ordered(startNumber: 1, delimiter: ".")
/// ```
///
/// - Since: 1.0.0
public enum ListType {
    /// An unordered (bulleted) list.
    ///
    /// - Parameter marker: The character used as the bullet marker.
    ///                     Common values are "-", "*", or "+".
    ///
    /// ## Markdown Examples
    /// ```markdown
    /// - Item (dash marker)
    /// * Item (asterisk marker)
    /// + Item (plus marker)
    /// ```
    case unordered(marker: Character)
    
    /// An ordered (numbered) list.
    ///
    /// - Parameters:
    ///   - startNumber: The starting number for the list (usually 1).
    ///   - delimiter: The character after the number ("." or ")").
    ///
    /// ## Markdown Examples
    /// ```markdown
    /// 1. Item (period delimiter)
    /// 1) Item (parenthesis delimiter)
    /// 5. Item (starting at 5)
    /// ```
    ///
    /// - Note: In Markdown, all items can use "1." and will be
    ///         automatically numbered in sequence.
    case ordered(startNumber: Int, delimiter: Character)
}

/// Represents a single item within a Markdown list.
///
/// List items can contain multiple block elements, allowing for
/// complex content like paragraphs, nested lists, and code blocks
/// within a single item.
///
/// ## Structure
///
/// A list item consists of:
/// - **Content**: One or more block elements
/// - **Tightness**: Whether the item is "tight" (no blank lines) or "loose"
///
/// ## Example
///
/// ```swift
/// let simpleItem = ListItem(
///     content: [.paragraph(content: [.text("Simple item")])],
///     tight: true
/// )
///
/// let complexItem = ListItem(
///     content: [
///         .paragraph(content: [.text("First paragraph")]),
///         .codeBlock(info: "swift", content: "let x = 1"),
///         .paragraph(content: [.text("Second paragraph")])
///     ],
///     tight: false
/// )
/// ```
///
/// - Since: 1.0.0
public struct ListItem {
    /// The block elements contained within this list item.
    ///
    /// A list item must contain at least one block element.
    /// Multiple blocks indicate a complex list item with multiple paragraphs,
    /// code blocks, or nested lists.
    public let content: [BlockElement]
    
    /// Indicates whether this is a "tight" list item.
    ///
    /// - Tight items: No blank lines between items, typically render without
    ///                paragraph spacing.
    /// - Loose items: Blank lines present, typically render with paragraph spacing.
    ///
    /// ## Rendering Difference
    /// ```markdown
    /// - Tight item 1
    /// - Tight item 2
    ///
    /// vs.
    ///
    /// - Loose item 1
    ///
    /// - Loose item 2
    /// ```
    public let tight: Bool
    
    /// Creates a new list item with the specified content and tightness.
    ///
    /// - Parameters:
    ///   - content: The block elements within this list item.
    ///              Must not be empty.
    ///   - tight: Whether this is a tight list item. Defaults to true.
    ///
    /// - Returns: A new `ListItem` instance.
    public init(content: [BlockElement], tight: Bool = true) {
        self.content = content
        self.tight = tight
    }
}