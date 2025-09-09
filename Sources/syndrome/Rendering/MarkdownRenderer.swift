//
//  MarkdownRenderer.swift
//  syndrome
//
//  Provides NSAttributedString rendering for parsed Markdown documents
//  on platforms that support it (macOS, iOS, tvOS, watchOS).
//

#if canImport(AppKit) || canImport(UIKit)

#if canImport(AppKit)
import AppKit
public typealias PlatformFont = NSFont
public typealias PlatformColor = NSColor
#elseif canImport(UIKit)
import UIKit
public typealias PlatformFont = UIFont
public typealias PlatformColor = UIColor
#endif

/// Configuration for rendering Markdown to attributed strings.
public struct MarkdownRenderingOptions {
    /// Base font for regular text
    public var baseFont: PlatformFont
    
    /// Color for regular text
    public var textColor: PlatformColor
    
    /// Color for links
    public var linkColor: PlatformColor
    
    /// Color for inline code and code blocks
    public var codeColor: PlatformColor
    
    /// Background color for inline code
    public var codeBackgroundColor: PlatformColor
    
    /// Background color for code blocks
    public var codeBlockBackgroundColor: PlatformColor
    
    /// Color for blockquote text
    public var blockquoteColor: PlatformColor
    
    /// Font name for monospace text (code)
    public var monospaceFontName: String?
    
    /// Indentation for list items
    public var listIndentation: CGFloat
    
    /// Spacing between paragraphs
    public var paragraphSpacing: CGFloat
    
    /// Line spacing within paragraphs
    public var lineSpacing: CGFloat
    
    /// Line height multiple for paragraphs
    public var lineHeightMultiple: CGFloat
    
    /// Spacing before paragraphs
    public var paragraphSpacingBefore: CGFloat
    
    /// Custom font weights for each header level (h1-h6)
    public var headerFontWeights: [PlatformFont.Weight]?
    
    /// Custom font scale multipliers for each header level (h1-h6)
    public var headerFontScales: [CGFloat]?
    
    /// Spacing between list items
    public var listItemSpacing: CGFloat
    
    /// Indentation for nested lists
    public var nestedListIndentation: CGFloat
    
    /// Padding for code blocks
    public var codeBlockPadding: CGFloat
    
    /// Border radius for code blocks (visual hint, not directly rendered)
    public var codeBlockBorderRadius: CGFloat
    
    /// Border color for code blocks
    public var codeBlockBorderColor: PlatformColor?
    
    /// Left border width for blockquotes
    public var blockquoteLeftBorderWidth: CGFloat
    
    /// Left border color for blockquotes
    public var blockquoteLeftBorderColor: PlatformColor?
    
    /// Background color for blockquotes
    public var blockquoteBackgroundColor: PlatformColor?
    
    /// Padding for blockquotes
    public var blockquotePadding: CGFloat
    
    /// Underline style for links
    public var linkUnderlineStyle: NSUnderlineStyle?
    
    /// Font weight for links
    public var linkFontWeight: PlatformFont.Weight?
    
    /// Creates default rendering options.
    public static var `default`: MarkdownRenderingOptions {
        #if canImport(AppKit)
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: NSFont.systemFontSize),
            textColor: .textColor,
            linkColor: .linkColor,
            codeColor: .textColor,
            codeBackgroundColor: .textBackgroundColor.withAlphaComponent(0.1),
            codeBlockBackgroundColor: .textBackgroundColor.withAlphaComponent(0.05),
            blockquoteColor: .secondaryLabelColor,
            monospaceFontName: "SF Mono",
            listIndentation: 28.0,
            paragraphSpacing: 14.0,
            lineSpacing: 3.0,
            lineHeightMultiple: 1.25,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: nil,
            headerFontScales: nil,
            listItemSpacing: 4.0,
            nestedListIndentation: 28.0,
            codeBlockPadding: 8.0,
            codeBlockBorderRadius: 4.0,
            codeBlockBorderColor: nil,
            blockquoteLeftBorderWidth: 3.0,
            blockquoteLeftBorderColor: nil,
            blockquoteBackgroundColor: nil,
            blockquotePadding: 8.0,
            linkUnderlineStyle: .single,
            linkFontWeight: nil
        )
        #else
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: UIFont.systemFontSize),
            textColor: .label,
            linkColor: .link,
            codeColor: .label,
            codeBackgroundColor: .secondarySystemBackground,
            codeBlockBackgroundColor: .tertiarySystemBackground,
            blockquoteColor: .secondaryLabel,
            monospaceFontName: "SF Mono",
            listIndentation: 28.0,
            paragraphSpacing: 14.0,
            lineSpacing: 3.0,
            lineHeightMultiple: 1.25,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: nil,
            headerFontScales: nil,
            listItemSpacing: 4.0,
            nestedListIndentation: 28.0,
            codeBlockPadding: 8.0,
            codeBlockBorderRadius: 4.0,
            codeBlockBorderColor: nil,
            blockquoteLeftBorderWidth: 3.0,
            blockquoteLeftBorderColor: nil,
            blockquoteBackgroundColor: nil,
            blockquotePadding: 8.0,
            linkUnderlineStyle: .single,
            linkFontWeight: nil
        )
        #endif
    }
    
    /// GitHub-style rendering theme.
    public static var github: MarkdownRenderingOptions {
        #if canImport(AppKit)
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 16),
            textColor: .textColor,
            linkColor: NSColor(red: 0.03, green: 0.46, blue: 0.87, alpha: 1.0),
            codeColor: .textColor,
            codeBackgroundColor: NSColor(white: 0.96, alpha: 1.0),
            codeBlockBackgroundColor: NSColor(white: 0.97, alpha: 1.0),
            blockquoteColor: .secondaryLabelColor,
            monospaceFontName: "SF Mono",
            listIndentation: 32.0,
            paragraphSpacing: 16.0,
            lineSpacing: 4.0,
            lineHeightMultiple: 1.5,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: [.semibold, .semibold, .semibold, .medium, .medium, .medium],
            headerFontScales: [2.0, 1.5, 1.25, 1.0, 0.875, 0.85],
            listItemSpacing: 4.0,
            nestedListIndentation: 32.0,
            codeBlockPadding: 16.0,
            codeBlockBorderRadius: 6.0,
            codeBlockBorderColor: NSColor(white: 0.9, alpha: 1.0),
            blockquoteLeftBorderWidth: 4.0,
            blockquoteLeftBorderColor: NSColor(white: 0.8, alpha: 1.0),
            blockquoteBackgroundColor: nil,
            blockquotePadding: 12.0,
            linkUnderlineStyle: nil,
            linkFontWeight: nil
        )
        #else
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 16),
            textColor: .label,
            linkColor: UIColor(red: 0.03, green: 0.46, blue: 0.87, alpha: 1.0),
            codeColor: .label,
            codeBackgroundColor: UIColor(white: 0.96, alpha: 1.0),
            codeBlockBackgroundColor: UIColor(white: 0.97, alpha: 1.0),
            blockquoteColor: .secondaryLabel,
            monospaceFontName: "SF Mono",
            listIndentation: 32.0,
            paragraphSpacing: 16.0,
            lineSpacing: 4.0,
            lineHeightMultiple: 1.5,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: [.semibold, .semibold, .semibold, .medium, .medium, .medium],
            headerFontScales: [2.0, 1.5, 1.25, 1.0, 0.875, 0.85],
            listItemSpacing: 4.0,
            nestedListIndentation: 32.0,
            codeBlockPadding: 16.0,
            codeBlockBorderRadius: 6.0,
            codeBlockBorderColor: UIColor(white: 0.9, alpha: 1.0),
            blockquoteLeftBorderWidth: 4.0,
            blockquoteLeftBorderColor: UIColor(white: 0.8, alpha: 1.0),
            blockquoteBackgroundColor: nil,
            blockquotePadding: 12.0,
            linkUnderlineStyle: nil,
            linkFontWeight: nil
        )
        #endif
    }
    
    /// Documentation-style rendering theme.
    public static var documentation: MarkdownRenderingOptions {
        #if canImport(AppKit)
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 15),
            textColor: .textColor,
            linkColor: .linkColor,
            codeColor: NSColor(red: 0.68, green: 0.18, blue: 0.89, alpha: 1.0),
            codeBackgroundColor: NSColor(white: 0.95, alpha: 1.0),
            codeBlockBackgroundColor: NSColor(white: 0.98, alpha: 1.0),
            blockquoteColor: NSColor(white: 0.4, alpha: 1.0),
            monospaceFontName: "SF Mono",
            listIndentation: 24.0,
            paragraphSpacing: 12.0,
            lineSpacing: 2.0,
            lineHeightMultiple: 1.3,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: [.bold, .semibold, .semibold, .medium, .medium, .regular],
            headerFontScales: [1.8, 1.4, 1.2, 1.1, 1.0, 0.9],
            listItemSpacing: 3.0,
            nestedListIndentation: 24.0,
            codeBlockPadding: 12.0,
            codeBlockBorderRadius: 4.0,
            codeBlockBorderColor: nil,
            blockquoteLeftBorderWidth: 2.0,
            blockquoteLeftBorderColor: NSColor(white: 0.7, alpha: 1.0),
            blockquoteBackgroundColor: NSColor(white: 0.98, alpha: 1.0),
            blockquotePadding: 10.0,
            linkUnderlineStyle: .single,
            linkFontWeight: .medium
        )
        #else
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 15),
            textColor: .label,
            linkColor: .link,
            codeColor: UIColor(red: 0.68, green: 0.18, blue: 0.89, alpha: 1.0),
            codeBackgroundColor: .secondarySystemBackground,
            codeBlockBackgroundColor: .tertiarySystemBackground,
            blockquoteColor: .secondaryLabel,
            monospaceFontName: "SF Mono",
            listIndentation: 24.0,
            paragraphSpacing: 12.0,
            lineSpacing: 2.0,
            lineHeightMultiple: 1.3,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: [.bold, .semibold, .semibold, .medium, .medium, .regular],
            headerFontScales: [1.8, 1.4, 1.2, 1.1, 1.0, 0.9],
            listItemSpacing: 3.0,
            nestedListIndentation: 24.0,
            codeBlockPadding: 12.0,
            codeBlockBorderRadius: 4.0,
            codeBlockBorderColor: nil,
            blockquoteLeftBorderWidth: 2.0,
            blockquoteLeftBorderColor: UIColor(white: 0.7, alpha: 1.0),
            blockquoteBackgroundColor: UIColor(white: 0.98, alpha: 1.0),
            blockquotePadding: 10.0,
            linkUnderlineStyle: .single,
            linkFontWeight: .medium
        )
        #endif
    }
    
    /// Chat application rendering theme.
    public static var chat: MarkdownRenderingOptions {
        #if canImport(AppKit)
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: NSFont.systemFontSize),
            textColor: .textColor,
            linkColor: .linkColor,
            codeColor: .textColor,
            codeBackgroundColor: NSColor(white: 0.92, alpha: 1.0),
            codeBlockBackgroundColor: NSColor(white: 0.95, alpha: 1.0),
            blockquoteColor: .secondaryLabelColor,
            monospaceFontName: "SF Mono",
            listIndentation: 28.0,
            paragraphSpacing: 14.0,
            lineSpacing: 3.0,
            lineHeightMultiple: 1.25,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: nil,
            headerFontScales: nil,
            listItemSpacing: 4.0,
            nestedListIndentation: 28.0,
            codeBlockPadding: 8.0,
            codeBlockBorderRadius: 8.0,
            codeBlockBorderColor: nil,
            blockquoteLeftBorderWidth: 3.0,
            blockquoteLeftBorderColor: NSColor.controlAccentColor.withAlphaComponent(0.5),
            blockquoteBackgroundColor: nil,
            blockquotePadding: 8.0,
            linkUnderlineStyle: nil,
            linkFontWeight: nil
        )
        #else
        return MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: UIFont.systemFontSize),
            textColor: .label,
            linkColor: .link,
            codeColor: .label,
            codeBackgroundColor: .quaternarySystemFill,
            codeBlockBackgroundColor: .tertiarySystemBackground,
            blockquoteColor: .secondaryLabel,
            monospaceFontName: "SF Mono",
            listIndentation: 28.0,
            paragraphSpacing: 14.0,
            lineSpacing: 3.0,
            lineHeightMultiple: 1.25,
            paragraphSpacingBefore: 0.0,
            headerFontWeights: nil,
            headerFontScales: nil,
            listItemSpacing: 4.0,
            nestedListIndentation: 28.0,
            codeBlockPadding: 8.0,
            codeBlockBorderRadius: 8.0,
            codeBlockBorderColor: nil,
            blockquoteLeftBorderWidth: 3.0,
            blockquoteLeftBorderColor: UIColor.tintColor.withAlphaComponent(0.5),
            blockquoteBackgroundColor: nil,
            blockquotePadding: 8.0,
            linkUnderlineStyle: nil,
            linkFontWeight: nil
        )
        #endif
    }
    
    /// Initializes rendering options with custom values.
    public init(
        baseFont: PlatformFont,
        textColor: PlatformColor,
        linkColor: PlatformColor,
        codeColor: PlatformColor,
        codeBackgroundColor: PlatformColor,
        codeBlockBackgroundColor: PlatformColor,
        blockquoteColor: PlatformColor,
        monospaceFontName: String? = nil,
        listIndentation: CGFloat = 28.0,
        paragraphSpacing: CGFloat = 14.0,
        lineSpacing: CGFloat = 3.0,
        lineHeightMultiple: CGFloat = 1.25,
        paragraphSpacingBefore: CGFloat = 0.0,
        headerFontWeights: [PlatformFont.Weight]? = nil,
        headerFontScales: [CGFloat]? = nil,
        listItemSpacing: CGFloat = 4.0,
        nestedListIndentation: CGFloat = 28.0,
        codeBlockPadding: CGFloat = 8.0,
        codeBlockBorderRadius: CGFloat = 4.0,
        codeBlockBorderColor: PlatformColor? = nil,
        blockquoteLeftBorderWidth: CGFloat = 3.0,
        blockquoteLeftBorderColor: PlatformColor? = nil,
        blockquoteBackgroundColor: PlatformColor? = nil,
        blockquotePadding: CGFloat = 8.0,
        linkUnderlineStyle: NSUnderlineStyle? = .single,
        linkFontWeight: PlatformFont.Weight? = nil
    ) {
        self.baseFont = baseFont
        self.textColor = textColor
        self.linkColor = linkColor
        self.codeColor = codeColor
        self.codeBackgroundColor = codeBackgroundColor
        self.codeBlockBackgroundColor = codeBlockBackgroundColor
        self.blockquoteColor = blockquoteColor
        self.monospaceFontName = monospaceFontName
        self.listIndentation = listIndentation
        self.paragraphSpacing = paragraphSpacing
        self.lineSpacing = lineSpacing
        self.lineHeightMultiple = lineHeightMultiple
        self.paragraphSpacingBefore = paragraphSpacingBefore
        self.headerFontWeights = headerFontWeights
        self.headerFontScales = headerFontScales
        self.listItemSpacing = listItemSpacing
        self.nestedListIndentation = nestedListIndentation
        self.codeBlockPadding = codeBlockPadding
        self.codeBlockBorderRadius = codeBlockBorderRadius
        self.codeBlockBorderColor = codeBlockBorderColor
        self.blockquoteLeftBorderWidth = blockquoteLeftBorderWidth
        self.blockquoteLeftBorderColor = blockquoteLeftBorderColor
        self.blockquoteBackgroundColor = blockquoteBackgroundColor
        self.blockquotePadding = blockquotePadding
        self.linkUnderlineStyle = linkUnderlineStyle
        self.linkFontWeight = linkFontWeight
    }
}

/// Renders parsed Markdown documents to NSAttributedString.
public struct MarkdownRenderer {
    private let options: MarkdownRenderingOptions
    
    /// Creates a new renderer with the specified options.
    /// - Parameter options: The rendering options to use. Defaults to `.default`.
    public init(options: MarkdownRenderingOptions = .default) {
        self.options = options
    }
    
    /// Renders a Markdown document to an attributed string.
    /// - Parameter document: The parsed Markdown document to render.
    /// - Returns: An attributed string representation of the document.
    public func render(_ document: MarkdownDocument) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, block) in document.blocks.enumerated() {
            if index > 0 {
                // Add paragraph spacing between blocks
                let paragraphBreak = NSAttributedString(
                    string: "\n",
                    attributes: [
                        .font: options.baseFont,
                        .paragraphStyle: createParagraphStyle(spacing: options.paragraphSpacing)
                    ]
                )
                result.append(paragraphBreak)
            }
            
            result.append(renderBlock(block))
        }
        
        return result
    }
    
    /// Renders a single block element to an attributed string.
    /// - Parameter block: The block element to render.
    /// - Returns: An attributed string representation of the block.
    public func renderBlock(_ block: BlockElement) -> NSAttributedString {
        switch block {
        case .heading(let level, let content):
            return renderHeading(level: level, content: content)
            
        case .paragraph(let content):
            return renderParagraph(content: content)
            
        case .list(let items, let type):
            return renderList(items: items, type: type, nestingLevel: 0)
            
        case .codeBlock(let info, let content):
            return renderCodeBlock(code: content, language: info)
            
        case .blockquote(let blocks):
            return renderBlockquote(blocks: blocks)
            
        case .horizontalRule:
            return renderHorizontalRule()
            
        case .htmlBlock(let content):
            return renderHTML(content: content)
        }
    }
    
    // MARK: - Block Rendering
    
    private func renderHeading(level: Int, content: [InlineElement]) -> NSAttributedString {
        let fontSize: CGFloat
        let font: PlatformFont
        
        // Use custom header scales if provided
        if let customScales = options.headerFontScales,
           level >= 1 && level <= customScales.count {
            fontSize = options.baseFont.pointSize * customScales[level - 1]
        } else {
            fontSize = options.baseFont.pointSize * headingScale(for: level)
        }
        
        // Use custom header weights if provided
        if let customWeights = options.headerFontWeights,
           level >= 1 && level <= customWeights.count {
            #if canImport(AppKit)
            font = NSFont.systemFont(ofSize: fontSize, weight: customWeights[level - 1])
            #else
            font = UIFont.systemFont(ofSize: fontSize, weight: customWeights[level - 1])
            #endif
        } else {
            font = PlatformFont.boldSystemFont(ofSize: fontSize)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: options.textColor,
            .paragraphStyle: createParagraphStyle()
        ]
        
        return renderInlineElements(content, baseAttributes: attributes)
    }
    
    private func renderParagraph(content: [InlineElement]) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: options.baseFont,
            .foregroundColor: options.textColor,
            .paragraphStyle: createParagraphStyle()
        ]
        
        return renderInlineElements(content, baseAttributes: attributes)
    }
    
    private func renderList(items: [ListItem], type: ListType, nestingLevel: Int = 0) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for (index, item) in items.enumerated() {
            let marker: String
            switch type {
            case .unordered:
                marker = "• "
            case .ordered(let startNumber, _):
                marker = "\(startNumber + index). "
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            let indentation = options.listIndentation + (CGFloat(nestingLevel) * options.nestedListIndentation)
            paragraphStyle.firstLineHeadIndent = CGFloat(nestingLevel) * options.nestedListIndentation
            paragraphStyle.headIndent = indentation
            paragraphStyle.paragraphSpacing = item.tight ? options.listItemSpacing : options.paragraphSpacing
            paragraphStyle.lineSpacing = options.lineSpacing
            paragraphStyle.lineHeightMultiple = options.lineHeightMultiple
            
            let markerAttributes: [NSAttributedString.Key: Any] = [
                .font: options.baseFont,
                .foregroundColor: options.textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            result.append(NSAttributedString(string: marker, attributes: markerAttributes))
            
            for block in item.content {
                result.append(renderBlock(block))
            }
            
            if index < items.count - 1 {
                let spacingAttributes: [NSAttributedString.Key: Any] = [
                    .font: options.baseFont,
                    .paragraphStyle: paragraphStyle
                ]
                result.append(NSAttributedString(string: "\n", attributes: spacingAttributes))
            }
        }
        
        return result
    }
    
    private func renderCodeBlock(code: String, language: String?) -> NSAttributedString {
        let font = monospacedFont(size: options.baseFont.pointSize)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = options.paragraphSpacing
        paragraphStyle.firstLineHeadIndent = options.codeBlockPadding
        paragraphStyle.headIndent = options.codeBlockPadding
        paragraphStyle.tailIndent = -options.codeBlockPadding
        paragraphStyle.lineSpacing = options.lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: options.codeColor,
            .backgroundColor: options.codeBlockBackgroundColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Note: Border rendering would require custom NSLayoutManager or view-level implementation
        // The border properties are provided as hints for SwiftUI or custom renderers
        
        return NSAttributedString(string: code, attributes: attributes)
    }
    
    private func renderBlockquote(blocks: [BlockElement]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = options.listIndentation + options.blockquotePadding
        paragraphStyle.headIndent = options.listIndentation + options.blockquotePadding
        paragraphStyle.tailIndent = -options.blockquotePadding
        paragraphStyle.lineSpacing = options.lineSpacing
        paragraphStyle.lineHeightMultiple = options.lineHeightMultiple
        
        for (index, block) in blocks.enumerated() {
            if index > 0 {
                result.append(NSAttributedString(string: "\n"))
            }
            
            let blockString = renderBlock(block)
            let mutableBlock = NSMutableAttributedString(attributedString: blockString)
            
            // Apply blockquote styling
            var blockquoteAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: options.blockquoteColor,
                .paragraphStyle: paragraphStyle
            ]
            
            // Apply background color if specified
            if let bgColor = options.blockquoteBackgroundColor {
                blockquoteAttributes[.backgroundColor] = bgColor
            }
            
            mutableBlock.addAttributes(blockquoteAttributes, range: NSRange(location: 0, length: mutableBlock.length))
            
            result.append(mutableBlock)
        }
        
        return result
    }
    
    private func renderHorizontalRule() -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: options.baseFont,
            .foregroundColor: options.textColor.withAlphaComponent(0.3),
            .paragraphStyle: createParagraphStyle()
        ]
        
        return NSAttributedString(string: "━━━━━━━━━━━━━━━━━━━━", attributes: attributes)
    }
    
    private func renderHTML(content: String) -> NSAttributedString {
        // For safety, we just render HTML as plain text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: monospacedFont(size: options.baseFont.pointSize * 0.9),
            .foregroundColor: options.textColor.withAlphaComponent(0.6)
        ]
        
        return NSAttributedString(string: content, attributes: attributes)
    }
    
    // MARK: - Inline Rendering
    
    private func renderInlineElements(_ elements: [InlineElement], baseAttributes: [NSAttributedString.Key: Any] = [:]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for element in elements {
            result.append(renderInlineElement(element, baseAttributes: baseAttributes))
        }
        
        return result
    }
    
    private func renderInlineElement(_ element: InlineElement, baseAttributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        switch element {
        case .text(let string):
            return NSAttributedString(string: string, attributes: baseAttributes)
            
        case .emphasis(let content):
            var attributes = baseAttributes
            if let font = attributes[.font] as? PlatformFont {
                attributes[.font] = italicFont(from: font)
            }
            return renderInlineElements(content, baseAttributes: attributes)
            
        case .strongEmphasis(let content):
            var attributes = baseAttributes
            if let font = attributes[.font] as? PlatformFont {
                attributes[.font] = boldFont(from: font)
            }
            return renderInlineElements(content, baseAttributes: attributes)
            
        case .code(let string):
            var attributes = baseAttributes
            attributes[.font] = monospacedFont(size: (baseAttributes[.font] as? PlatformFont)?.pointSize ?? options.baseFont.pointSize)
            attributes[.backgroundColor] = options.codeBackgroundColor
            attributes[.foregroundColor] = options.codeColor
            return NSAttributedString(string: string, attributes: attributes)
            
        case .link(let text, let url, let title):
            var attributes = baseAttributes
            attributes[.foregroundColor] = options.linkColor
            if let underlineStyle = options.linkUnderlineStyle {
                attributes[.underlineStyle] = underlineStyle.rawValue
            }
            attributes[.link] = url
            if let title = title {
                attributes[.toolTip] = title
            }
            // Apply link font weight if specified
            if let linkWeight = options.linkFontWeight,
               let currentFont = attributes[.font] as? PlatformFont {
                #if canImport(AppKit)
                attributes[.font] = NSFont.systemFont(ofSize: currentFont.pointSize, weight: linkWeight)
                #else
                attributes[.font] = UIFont.systemFont(ofSize: currentFont.pointSize, weight: linkWeight)
                #endif
            }
            return renderInlineElements(text, baseAttributes: attributes)
            
        case .image(let alt, _, _):
            var attributes = baseAttributes
            attributes[.foregroundColor] = options.textColor.withAlphaComponent(0.6)
            let altText = extractPlainText(from: alt)
            return NSAttributedString(string: "[Image: \(altText)]", attributes: attributes)
            
        case .htmlInline(let content):
            var attributes = baseAttributes
            attributes[.foregroundColor] = options.textColor.withAlphaComponent(0.6)
            return NSAttributedString(string: content, attributes: attributes)
            
        case .softBreak:
            return NSAttributedString(string: " ", attributes: baseAttributes)
            
        case .hardBreak:
            return NSAttributedString(string: "\n", attributes: baseAttributes)
        }
    }
    
    // MARK: - Helper Methods
    
    private func headingScale(for level: Int) -> CGFloat {
        switch level {
        case 1: return 2.0
        case 2: return 1.5
        case 3: return 1.17
        case 4: return 1.0
        case 5: return 0.83
        case 6: return 0.75
        default: return 1.0
        }
    }
    
    private func createParagraphStyle(spacing: CGFloat? = nil, lineSpacing: CGFloat? = nil, spacingBefore: CGFloat? = nil) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = spacing ?? options.paragraphSpacing
        style.paragraphSpacingBefore = spacingBefore ?? options.paragraphSpacingBefore
        style.lineSpacing = lineSpacing ?? options.lineSpacing
        style.lineHeightMultiple = options.lineHeightMultiple
        return style
    }
    
    private func monospacedFont(size: CGFloat) -> PlatformFont {
        if let fontName = options.monospaceFontName,
           let font = PlatformFont(name: fontName, size: size) {
            return font
        }
        
        #if canImport(AppKit)
        return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
        #else
        if #available(iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
        } else {
            return UIFont(name: "Menlo", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        #endif
    }
    
    private func italicFont(from font: PlatformFont) -> PlatformFont {
        #if canImport(AppKit)
        let descriptor = font.fontDescriptor.withSymbolicTraits(.italic)
        return NSFont(descriptor: descriptor, size: font.pointSize) ?? font
        #else
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }
        return font
        #endif
    }
    
    private func boldFont(from font: PlatformFont) -> PlatformFont {
        #if canImport(AppKit)
        let descriptor = font.fontDescriptor.withSymbolicTraits(.bold)
        return NSFont(descriptor: descriptor, size: font.pointSize) ?? font
        #else
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: font.pointSize)
        }
        return font
        #endif
    }
    
    private func extractPlainText(from elements: [InlineElement]) -> String {
        var result = ""
        for element in elements {
            switch element {
            case .text(let string):
                result += string
            case .emphasis(let content), .strongEmphasis(let content):
                result += extractPlainText(from: content)
            case .code(let string):
                result += string
            case .link(let text, _, _):
                result += extractPlainText(from: text)
            case .image(let alt, _, _):
                result += extractPlainText(from: alt)
            case .htmlInline(let content):
                result += content
            case .softBreak:
                result += " "
            case .hardBreak:
                result += "\n"
            }
        }
        return result
    }
}

// MARK: - Convenience Extensions

public extension MarkdownDocument {
    /// Renders this document to an attributed string using default options.
    /// - Returns: An attributed string representation of the document.
    /// - Note: Only available on platforms that support NSAttributedString.
    func attributedString() -> NSAttributedString {
        let renderer = MarkdownRenderer()
        return renderer.render(self)
    }
    
    /// Renders this document to an attributed string using custom options.
    /// - Parameter options: The rendering options to use.
    /// - Returns: An attributed string representation of the document.
    /// - Note: Only available on platforms that support NSAttributedString.
    func attributedString(options: MarkdownRenderingOptions) -> NSAttributedString {
        let renderer = MarkdownRenderer(options: options)
        return renderer.render(self)
    }
}

public extension String {
    /// Parses this string as Markdown and renders it to an attributed string.
    /// - Returns: An attributed string representation of the parsed Markdown.
    /// - Note: Only available on platforms that support NSAttributedString.
    func markdownAttributedString() -> NSAttributedString {
        let document = MarkdownParser.parse(self)
        return document.attributedString()
    }
    
    /// Parses this string as Markdown and renders it to an attributed string with custom options.
    /// - Parameter options: The rendering options to use.
    /// - Returns: An attributed string representation of the parsed Markdown.
    /// - Note: Only available on platforms that support NSAttributedString.
    func markdownAttributedString(options: MarkdownRenderingOptions) -> NSAttributedString {
        let document = MarkdownParser.parse(self)
        return document.attributedString(options: options)
    }
}

#endif // canImport(AppKit) || canImport(UIKit)