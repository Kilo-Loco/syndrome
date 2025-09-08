import Foundation

/// Represents a parsed Markdown document as a structured model.
///
/// `MarkdownDocument` is the top-level container returned by the parser,
/// containing all parsed block elements and optional metadata.
///
/// ## Structure
///
/// A document consists of:
/// - **Blocks**: An ordered array of block-level elements (headings, paragraphs, lists, etc.)
/// - **Metadata**: Optional key-value pairs for document-level information
///
/// ## Example
///
/// ```swift
/// let markdown = """
///     # Document Title
///     
///     First paragraph.
///     
///     - List item
///     """
///
/// let document = MarkdownParser.parse(markdown)
///
/// // Access blocks
/// for block in document.blocks {
///     print("Block type: \(block)")
/// }
///
/// // Check if document is empty
/// if document.blocks.isEmpty {
///     print("Empty document")
/// }
/// ```
///
/// ## Traversing the Document
///
/// ```swift
/// extension MarkdownDocument {
///     var headings: [BlockElement] {
///         blocks.compactMap { block in
///             if case .heading = block {
///                 return block
///             }
///             return nil
///         }
///     }
/// }
/// ```
///
/// - Since: 1.0.0
public struct MarkdownDocument {
    /// The ordered array of block-level elements in the document.
    ///
    /// Blocks appear in the same order as they were parsed from the source text.
    /// An empty array indicates an empty or whitespace-only document.
    public let blocks: [BlockElement]
    
    /// Optional metadata associated with the document.
    ///
    /// This dictionary can store document-level information such as
    /// front matter, parsing options, or custom attributes.
    ///
    /// - Note: Currently, the parser does not populate metadata.
    ///         This field is reserved for future extensions.
    public let metadata: [String: String]
    
    /// Creates a new Markdown document with the specified blocks and metadata.
    ///
    /// - Parameters:
    ///   - blocks: The block-level elements that make up the document.
    ///   - metadata: Optional metadata dictionary. Defaults to empty.
    ///
    /// - Returns: A new `MarkdownDocument` instance.
    public init(blocks: [BlockElement], metadata: [String: String] = [:]) {
        self.blocks = blocks
        self.metadata = metadata
    }
}