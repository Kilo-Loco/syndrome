//
//  SwiftUITests.swift
//  syndromeTests
//
//  Tests for SwiftUI components and features
//

import Testing
import Foundation
@testable import syndrome

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI

@Suite("SwiftUI Components")
struct SwiftUITests {
    
    @Test("MarkdownView initializes correctly")
    func testMarkdownViewInitialization() {
        let content = "# Test"
        let _ = MarkdownView(content)
        // Test passes if initialization doesn't crash
        #expect(true)
    }
    
    @Test("MarkdownView with custom options")
    func testMarkdownViewWithOptions() {
        let content = "**Bold** text"
        let _ = MarkdownView(content, options: .github)
        // Test passes if initialization doesn't crash
        #expect(true)
    }
    
    @Test("StreamingMarkdownView initializes correctly")
    func testStreamingMarkdownViewInitialization() {
        var content = "# Streaming"
        let binding = Binding(get: { content }, set: { content = $0 })
        let _ = StreamingMarkdownView(content: binding)
        // Test passes if initialization doesn't crash
        #expect(true)
    }
    
    @Test("Text markdown extension works")
    func testTextMarkdownExtension() {
        let _ = Text(markdown: "**Bold** and *italic*")
        // Test passes if initialization doesn't crash
        #expect(true)
    }
    
    @Test("Text markdown with custom options")
    func testTextMarkdownWithOptions() {
        let _ = Text(markdown: "# Header", options: .documentation)
        // Test passes if initialization doesn't crash
        #expect(true)
    }
    
    @Test("Environment markdown options modifier")
    func testMarkdownOptionsModifier() {
        let _ = Text("Test")
            .markdownOptions(.chat)
        // Test passes if initialization doesn't crash
        #expect(true)
    }
}

@Suite("Pre-built Themes")
struct ThemeTests {
    
    @Test("Default theme has correct values")
    func testDefaultTheme() {
        let options = MarkdownRenderingOptions.default
        #expect(options.paragraphSpacing == 14.0)
        #expect(options.listIndentation == 28.0)
        #expect(options.lineSpacing == 3.0)
    }
    
    @Test("GitHub theme has distinct values")
    func testGitHubTheme() {
        let options = MarkdownRenderingOptions.github
        #expect(options.paragraphSpacing == 16.0)
        #expect(options.listIndentation == 32.0)
        #expect(options.lineSpacing == 4.0)
        #expect(options.baseFont.pointSize == 16)
    }
    
    @Test("Documentation theme has distinct values")
    func testDocumentationTheme() {
        let options = MarkdownRenderingOptions.documentation
        #expect(options.paragraphSpacing == 12.0)
        #expect(options.listIndentation == 24.0)
        #expect(options.lineSpacing == 2.0)
        #expect(options.baseFont.pointSize == 15)
    }
    
    @Test("Chat theme has distinct values")
    func testChatTheme() {
        let options = MarkdownRenderingOptions.chat
        #expect(options.paragraphSpacing == 14.0)
        #expect(options.listIndentation == 28.0)
        #expect(options.lineSpacing == 3.0)
    }
    
    @Test("Themes produce different renderings")
    func testThemesProduceDifferentOutput() {
        let markdown = "# Test\n**Bold** text"
        let document = MarkdownParser.parse(markdown)
        
        let defaultRender = document.attributedString(options: .default)
        let githubRender = document.attributedString(options: .github)
        let docRender = document.attributedString(options: .documentation)
        let chatRender = document.attributedString(options: .chat)
        
        // Check that different themes produce different attributes
        #expect(defaultRender.length > 0)
        #expect(githubRender.length > 0)
        #expect(docRender.length > 0)
        #expect(chatRender.length > 0)
        
        // Verify font sizes are different
        var defaultFontSize: CGFloat = 0
        var githubFontSize: CGFloat = 0
        
        defaultRender.enumerateAttribute(.font, in: NSRange(location: 0, length: 1)) { value, range, _ in
            if let font = value as? PlatformFont {
                defaultFontSize = font.pointSize
            }
        }
        
        githubRender.enumerateAttribute(.font, in: NSRange(location: 0, length: 1)) { value, range, _ in
            if let font = value as? PlatformFont {
                githubFontSize = font.pointSize
            }
        }
        
        #expect(githubFontSize != defaultFontSize)
    }
}

@Suite("Line Spacing Feature")
struct LineSpacingTests {
    
    @Test("Line spacing is applied to paragraphs")
    func testLineSpacingInParagraphs() {
        let markdown = "This is a paragraph\nwith multiple lines\nto test line spacing"
        let document = MarkdownParser.parse(markdown)
        
        #if canImport(UIKit)
        let options = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: .label,
            linkColor: .link,
            codeColor: .label,
            codeBackgroundColor: .secondarySystemBackground,
            codeBlockBackgroundColor: .tertiarySystemBackground,
            blockquoteColor: .secondaryLabel,
            lineSpacing: 5.0
        )
        #else
        let options = MarkdownRenderingOptions(
            baseFont: .systemFont(ofSize: 14),
            textColor: .textColor,
            linkColor: .linkColor,
            codeColor: .textColor,
            codeBackgroundColor: .textBackgroundColor,
            codeBlockBackgroundColor: .textBackgroundColor,
            blockquoteColor: .secondaryLabelColor,
            lineSpacing: 5.0
        )
        #endif
        
        let rendered = document.attributedString(options: options)
        
        // Check that line spacing is applied
        var hasLineSpacing = false
        rendered.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSRange(location: 0, length: rendered.length)) { value, range, _ in
            if let style = value as? NSParagraphStyle {
                if style.lineSpacing == 5.0 {
                    hasLineSpacing = true
                }
            }
        }
        
        #expect(hasLineSpacing)
    }
    
    @Test("Different line spacing values work")
    func testDifferentLineSpacingValues() {
        let markdown = "Test paragraph"
        let document = MarkdownParser.parse(markdown)
        
        for spacing in [0.0, 2.0, 5.0, 10.0] {
            #if canImport(UIKit)
            let options = MarkdownRenderingOptions(
                baseFont: .systemFont(ofSize: 14),
                textColor: .label,
                linkColor: .link,
                codeColor: .label,
                codeBackgroundColor: .secondarySystemBackground,
                codeBlockBackgroundColor: .tertiarySystemBackground,
                blockquoteColor: .secondaryLabel,
                lineSpacing: spacing
            )
            #else
            let options = MarkdownRenderingOptions(
                baseFont: .systemFont(ofSize: 14),
                textColor: .textColor,
                linkColor: .linkColor,
                codeColor: .textColor,
                codeBackgroundColor: .textBackgroundColor,
                codeBlockBackgroundColor: .textBackgroundColor,
                blockquoteColor: .secondaryLabelColor,
                lineSpacing: spacing
            )
            #endif
            
            let rendered = document.attributedString(options: options)
            
            // Check that we have content
            #expect(rendered.length > 0, "Rendered string should not be empty")
            
            var foundSpacing: CGFloat? = nil
            var foundAnyStyle = false
            rendered.enumerateAttribute(NSAttributedString.Key.paragraphStyle, in: NSRange(location: 0, length: rendered.length)) { value, range, _ in
                if let style = value as? NSParagraphStyle {
                    foundAnyStyle = true
                    foundSpacing = style.lineSpacing
                }
            }
            
            #expect(foundAnyStyle, "Should find paragraph style for spacing \(spacing)")
            if let foundSpacing = foundSpacing {
                // Use tolerance for floating-point comparison
                let tolerance: CGFloat = 0.001
                #expect(abs(foundSpacing - spacing) < tolerance, "Line spacing should be \(spacing) but was \(foundSpacing)")
            } else {
                Issue.record("No line spacing found for spacing value \(spacing)")
            }
        }
    }
}

@Suite("Streaming Support")
struct StreamingTests {
    
    @Test("Streaming view handles content updates")
    func testStreamingContentUpdates() {
        var content = "Initial"
        let binding = Binding(
            get: { content },
            set: { content = $0 }
        )
        
        let _ = StreamingMarkdownView(content: binding)
        
        // Simulate content updates
        content = "# Updated"
        content = "# Updated\n**Bold** text"
        content = "# Updated\n**Bold** text\n- List item"
        
        // Test passes if updates don't crash
        #expect(true)
    }
    
    @Test("Streaming handles empty content")
    func testStreamingEmptyContent() {
        var content = ""
        let binding = Binding(
            get: { content },
            set: { content = $0 }
        )
        
        let _ = StreamingMarkdownView(content: binding)
        // Test passes if initialization doesn't crash
        #expect(true)
    }
    
    @Test("Streaming handles large content")
    func testStreamingLargeContent() {
        var content = String(repeating: "# Heading\nParagraph text\n", count: 100)
        let binding = Binding(
            get: { content },
            set: { content = $0 }
        )
        
        let view = StreamingMarkdownView(content: binding, options: .default)
        #expect(view != nil)
    }
}

#endif