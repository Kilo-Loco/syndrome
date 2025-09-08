//
//  RenderingOptionsTests.swift
//  syndromeTests
//
//  Tests for MarkdownRenderingOptions improvements
//

import Testing
import Foundation
@testable import syndrome

#if canImport(UIKit) || canImport(AppKit)

@Suite("Rendering Options Improvements")
struct RenderingOptionsTests {
    
    @Test("Default spacing values are improved")
    func testImprovedDefaults() {
        let options = MarkdownRenderingOptions.default
        
        // Check that new defaults are better than old ones
        #expect(options.paragraphSpacing == 14.0, "Paragraph spacing should be 14.0")
        #expect(options.listIndentation == 28.0, "List indentation should be 28.0")
        #expect(options.lineSpacing == 3.0, "Line spacing should be 3.0")
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
        
        // Verify Documentation theme has distinct values
        #expect(docTheme.paragraphSpacing == 12.0)
        #expect(docTheme.listIndentation == 24.0)
        #expect(docTheme.lineSpacing == 2.0)
        
        // Verify Chat theme has appropriate values
        #expect(chatTheme.paragraphSpacing == 14.0)
        #expect(chatTheme.listIndentation == 28.0)
        #expect(chatTheme.lineSpacing == 3.0)
    }
    
    @Test("Line spacing is included in rendering")
    func testLineSpacingInRendering() {
        let markdown = "This is a test\nparagraph with\nmultiple lines"
        let document = MarkdownParser.parse(markdown)
        
        // Test with custom line spacing
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
            lineSpacing: 7.0
        )
        
        let rendered = document.attributedString(options: customOptions)
        
        // Check that the attributed string is not empty
        #expect(rendered.length > 0)
        
        // Verify paragraph style is applied
        var hasParagraphStyle = false
        rendered.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSRange(location: 0, length: rendered.length)) { value, range, _ in
            if value != nil {
                hasParagraphStyle = true
            }
        }
        
        #expect(hasParagraphStyle, "Paragraph style should be applied")
    }
    
    @Test("Themes work with different content types")
    func testThemesWithContent() {
        let testCases = [
            ("# Heading", "heading"),
            ("**Bold** text", "bold"),
            ("*Italic* text", "italic"),
            ("`code` inline", "code"),
            ("[Link](url)", "link"),
            ("> Quote", "quote"),
            ("- List item", "list")
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
    
    @Test("Custom options initialization works")
    func testCustomOptionsInit() {
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
            lineSpacing: 5.0
        )
        
        #expect(options.baseFont.pointSize == 18)
        #expect(options.monospaceFontName == "Courier")
        #expect(options.listIndentation == 40.0)
        #expect(options.paragraphSpacing == 20.0)
        #expect(options.lineSpacing == 5.0)
    }
}

#endif