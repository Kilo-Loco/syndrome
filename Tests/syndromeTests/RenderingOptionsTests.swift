//
//  RenderingOptionsTests.swift
//  syndromeTests
//
//  Tests for enhanced MarkdownRenderingOptions features
//

import Testing
import Foundation
@testable import syndrome

#if canImport(UIKit) || canImport(AppKit)

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@Suite("Rendering Options Improvements")
struct RenderingOptionsTests {
    
    @Test("Default spacing values are improved")
    func testImprovedDefaults() {
        let options = MarkdownRenderingOptions.default
        
        // Check that new defaults are better than old ones
        #expect(options.paragraphSpacing == 14.0, "Paragraph spacing should be 14.0")
        #expect(options.listIndentation == 28.0, "List indentation should be 28.0")
        #expect(options.lineSpacing == 3.0, "Line spacing should be 3.0")
        #expect(options.lineHeightMultiple == 1.25, "Line height multiple should be 1.25")
        #expect(options.listItemSpacing == 4.0, "List item spacing should be 4.0")
        #expect(options.codeBlockPadding == 8.0, "Code block padding should be 8.0")
    }
    
    @Test("Pre-built themes exist and have distinct values")
    func testPreBuiltThemes() {
        let defaultTheme = MarkdownRenderingOptions.default
        let githubTheme = MarkdownRenderingOptions.github
        let docTheme = MarkdownRenderingOptions.documentation
        let chatTheme = MarkdownRenderingOptions.chat
        
        // Verify themes exist
        #expect(defaultTheme.baseFont != nil)
        #expect(githubTheme.baseFont != nil)
        #expect(docTheme.baseFont != nil)
        #expect(chatTheme.baseFont != nil)
        
        // Verify GitHub theme has distinct values
        #expect(githubTheme.paragraphSpacing == 16.0)
        #expect(githubTheme.listIndentation == 32.0)
        #expect(githubTheme.lineSpacing == 4.0)
        #expect(githubTheme.lineHeightMultiple == 1.5)
        #expect(githubTheme.headerFontWeights != nil)
        #expect(githubTheme.headerFontScales != nil)
        
        // Verify Documentation theme has distinct values
        #expect(docTheme.paragraphSpacing == 12.0)
        #expect(docTheme.listIndentation == 24.0)
        #expect(docTheme.lineSpacing == 2.0)
        #expect(docTheme.lineHeightMultiple == 1.3)
        #expect(docTheme.headerFontWeights != nil)
        #expect(docTheme.linkFontWeight == .medium)
        
        // Verify Chat theme has appropriate values
        #expect(chatTheme.paragraphSpacing == 14.0)
        #expect(chatTheme.listIndentation == 28.0)
        #expect(chatTheme.lineSpacing == 3.0)
        #expect(chatTheme.lineHeightMultiple == 1.25)
        #expect(chatTheme.codeBlockBorderRadius == 8.0)
    }
    
    @Test("Line height multiple is applied")
    func testLineHeightMultiple() {
        let markdown = "This is a test\nparagraph with\nmultiple lines"
        let document = MarkdownParser.parse(markdown)
        
        // Test with custom line spacing and line height multiple
        let customOptions = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            monospaceFontName: nil,
            listIndentation: 28.0,
            paragraphSpacing: 14.0,
            lineSpacing: 7.0,
            lineHeightMultiple: 1.8
        )
        
        let rendered = document.attributedString(options: customOptions)
        
        // Check that the attributed string is not empty
        #expect(rendered.length > 0)
        
        // Verify paragraph style is applied with line height multiple
        var foundLineHeightMultiple = false
        rendered.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSRange(location: 0, length: rendered.length)) { value, _, _ in
            if let style = value as? NSParagraphStyle {
                if abs(style.lineHeightMultiple - 1.8) < 0.001 {
                    foundLineHeightMultiple = true
                }
            }
        }
        
        #expect(foundLineHeightMultiple, "Line height multiple should be applied")
    }
    
    @Test("Custom header typography")
    func testCustomHeaderTypography() {
        let markdown = """
        # H1 Header
        ## H2 Header
        ### H3 Header
        """
        let document = MarkdownParser.parse(markdown)
        
        let customOptions = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 10),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            headerFontWeights: [.heavy, .bold, .semibold, .medium, .regular, .light],
            headerFontScales: [3.0, 2.5, 2.0, 1.5, 1.2, 1.0]
        )
        
        let rendered = document.attributedString(options: customOptions)
        
        // Headers should be rendered with custom scales
        #expect(rendered.length > 0, "Headers should be rendered")
        
        // Check that the first header has the expected size (base 10 * scale 3.0 = 30)
        var foundExpectedSize = false
        rendered.enumerateAttribute(.font, in: NSRange(location: 0, length: min(10, rendered.length))) { value, _, _ in
            if let font = value as? PlatformFont {
                if abs(font.pointSize - 30.0) < 0.1 {
                    foundExpectedSize = true
                }
            }
        }
        
        #expect(foundExpectedSize, "H1 should have custom scaled font size")
    }
    
    @Test("List item spacing configuration")
    func testListItemSpacing() {
        let markdown = """
        - First item
        - Second item
        - Third item
        """
        let document = MarkdownParser.parse(markdown)
        
        let customOptions = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            listItemSpacing: 10.0
        )
        
        let rendered = document.attributedString(options: customOptions)
        
        // List should be rendered with custom item spacing
        #expect(rendered.length > 0, "List should be rendered")
    }
    
    @Test("Blockquote enhanced styling")
    func testBlockquoteEnhancedStyling() {
        let markdown = "> This is a blockquote"
        let document = MarkdownParser.parse(markdown)
        
        let bgColor = PlatformColor(white: 0.95, alpha: 1.0)
        let customOptions = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            blockquoteLeftBorderWidth: 5.0,
            blockquoteBackgroundColor: bgColor,
            blockquotePadding: 15.0
        )
        
        let rendered = document.attributedString(options: customOptions)
        
        // Blockquote should have background color
        var foundBackgroundColor = false
        rendered.enumerateAttribute(NSAttributedString.Key.backgroundColor, in: NSRange(location: 0, length: rendered.length)) { value, _, _ in
            if value != nil {
                foundBackgroundColor = true
            }
        }
        
        #expect(foundBackgroundColor, "Blockquote should have background color")
    }
    
    @Test("Link styling customization")
    func testLinkStylingCustomization() {
        let markdown = "[Test Link](https://example.com)"
        let document = MarkdownParser.parse(markdown)
        
        // Test without underline
        let noUnderlineOptions = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            linkUnderlineStyle: nil,
            linkFontWeight: .bold
        )
        
        let rendered = document.attributedString(options: noUnderlineOptions)
        
        // Link should be rendered
        #expect(rendered.length > 0, "Link should be rendered")
        
        // Check for link attribute
        var hasLink = false
        rendered.enumerateAttribute(.link, in: NSRange(location: 0, length: rendered.length)) { value, _, _ in
            if value != nil {
                hasLink = true
            }
        }
        
        #expect(hasLink, "Should have link attribute")
    }
    
    @Test("Code block padding")
    func testCodeBlockPadding() {
        let markdown = "```\ncode block content\n```"
        let document = MarkdownParser.parse(markdown)
        
        let customOptions = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            codeBlockPadding: 20.0,
            codeBlockBorderRadius: 10.0
        )
        
        let rendered = document.attributedString(options: customOptions)
        
        // Code block should be rendered with padding
        var foundPadding = false
        rendered.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSRange(location: 0, length: rendered.length)) { value, _, _ in
            if let style = value as? NSParagraphStyle {
                if abs(style.firstLineHeadIndent - 20.0) < 0.1 {
                    foundPadding = true
                }
            }
        }
        
        #expect(foundPadding, "Code block should have padding")
    }
    
    @Test("Themes work with different content types")
    func testThemesWithContent() {
        let testCases = [
            ("# Heading with emoji 🎉", "heading"),
            ("**Bold** text", "bold"),
            ("*Italic* text", "italic"),
            ("`code` inline", "code"),
            ("[Link](url)", "link"),
            ("> Quote", "quote"),
            ("- List item", "list"),
            ("```\ncode block\n```", "code block")
        ]
        
        for (markdown, description) in testCases {
            let document = MarkdownParser.parse(markdown)
            
            // Test each theme
            for theme in [MarkdownRenderingOptions.default, .github, .documentation, .chat] {
                let rendered = document.attributedString(options: theme)
                #expect(rendered.length > 0, "Theme should render \(description)")
            }
        }
    }
    
    @Test("Custom options initialization with all parameters")
    func testCustomOptionsInitAllParameters() {
        let options = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 18),
            textColor: MarkdownRenderingOptions.default.textColor,
            linkColor: MarkdownRenderingOptions.default.linkColor,
            codeColor: MarkdownRenderingOptions.default.codeColor,
            codeBackgroundColor: MarkdownRenderingOptions.default.codeBackgroundColor,
            codeBlockBackgroundColor: MarkdownRenderingOptions.default.codeBlockBackgroundColor,
            blockquoteColor: MarkdownRenderingOptions.default.blockquoteColor,
            monospaceFontName: "Courier",
            listIndentation: 40.0,
            paragraphSpacing: 20.0,
            lineSpacing: 5.0,
            lineHeightMultiple: 1.5,
            paragraphSpacingBefore: 10.0,
            headerFontWeights: [.bold, .bold, .semibold, .medium, .regular, .light],
            headerFontScales: [2.5, 2.0, 1.5, 1.2, 1.0, 0.9],
            listItemSpacing: 6.0,
            nestedListIndentation: 35.0,
            codeBlockPadding: 12.0,
            codeBlockBorderRadius: 6.0,
            codeBlockBorderColor: PlatformColor.gray,
            blockquoteLeftBorderWidth: 4.0,
            blockquoteLeftBorderColor: PlatformColor.blue,
            blockquoteBackgroundColor: PlatformColor(white: 0.98, alpha: 1.0),
            blockquotePadding: 10.0,
            linkUnderlineStyle: .double,
            linkFontWeight: .semibold
        )
        
        #expect(options.baseFont.pointSize == 18)
        #expect(options.monospaceFontName == "Courier")
        #expect(options.listIndentation == 40.0)
        #expect(options.paragraphSpacing == 20.0)
        #expect(options.lineSpacing == 5.0)
        #expect(options.lineHeightMultiple == 1.5)
        #expect(options.paragraphSpacingBefore == 10.0)
        #expect(options.headerFontWeights?.count == 6)
        #expect(options.headerFontScales?.count == 6)
        #expect(options.listItemSpacing == 6.0)
        #expect(options.nestedListIndentation == 35.0)
        #expect(options.codeBlockPadding == 12.0)
        #expect(options.codeBlockBorderRadius == 6.0)
        #expect(options.blockquoteLeftBorderWidth == 4.0)
        #expect(options.blockquotePadding == 10.0)
        #expect(options.linkUnderlineStyle == .double)
        #expect(options.linkFontWeight == .semibold)
    }
}

#endif