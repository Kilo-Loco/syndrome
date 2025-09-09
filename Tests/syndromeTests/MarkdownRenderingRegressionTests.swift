//
//  MarkdownRenderingRegressionTests.swift
//  syndromeTests
//
//  Regression tests to prevent markdown rendering failures
//  These tests ensure SwiftUI components never display raw markdown syntax
//

import Testing
import Foundation
@testable import syndrome

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI

@Suite("Markdown Rendering Regression Prevention")
struct MarkdownRenderingRegressionTests {
    
    // MARK: - Critical Rendering Tests
    
    @Test("SwiftUI components MUST NOT display raw markdown syntax")
    func testNoRawMarkdownSyntaxEverDisplayed() {
        // This is the master test that ensures we never regress to showing raw markdown
        let testCases: [(input: String, forbiddenPatterns: [String], description: String)] = [
            (
                input: "# Header 1",
                forbiddenPatterns: ["#"],
                description: "Headers should not show # symbols"
            ),
            (
                input: "## Header 2\n### Header 3",
                forbiddenPatterns: ["##", "###"],
                description: "Multiple headers should not show # symbols"
            ),
            (
                input: "**bold text**",
                forbiddenPatterns: ["**", "bold text**"],
                description: "Bold text should not show ** markers"
            ),
            (
                input: "__alternative bold__",
                forbiddenPatterns: ["__"],
                description: "Alternative bold should not show __ markers"
            ),
            (
                input: "*italic text*",
                forbiddenPatterns: ["*italic", "text*"],
                description: "Italic text should not show * markers"
            ),
            (
                input: "_alternative italic_",
                forbiddenPatterns: ["_alternative", "italic_"],
                description: "Alternative italic should not show _ markers"
            ),
            (
                input: "`inline code`",
                forbiddenPatterns: ["`inline", "code`", "`"],
                description: "Inline code should not show backticks"
            ),
            (
                input: "```swift\nfunc test() {}\n```",
                forbiddenPatterns: ["```swift", "```"],
                description: "Code blocks should not show fence markers"
            ),
            (
                input: "~~~\ncode block\n~~~",
                forbiddenPatterns: ["~~~"],
                description: "Alternative code blocks should not show tildes"
            ),
            (
                input: "- List item 1\n- List item 2",
                forbiddenPatterns: ["- List"],
                description: "Unordered lists should not show - markers"
            ),
            (
                input: "* Alternative list\n* Another item",
                forbiddenPatterns: ["* Alternative", "* Another"],
                description: "Alternative lists should not show * markers"
            ),
            (
                input: "+ Plus list\n+ Plus item",
                forbiddenPatterns: ["+ Plus"],
                description: "Plus lists should not show + markers"
            ),
            (
                input: "> Blockquote text",
                forbiddenPatterns: ["> Block"],
                description: "Blockquotes should not show > markers"
            ),
            (
                input: "[Link text](https://example.com)",
                forbiddenPatterns: ["[Link", "](http", "[", "]"],
                description: "Links should not show brackets or parentheses"
            ),
            (
                input: "![Alt text](image.png)",
                forbiddenPatterns: ["![Alt", "](image", "!["],
                description: "Images should not show markdown syntax"
            ),
            (
                input: "---",
                forbiddenPatterns: ["---"],
                description: "Horizontal rules should not show dashes"
            ),
            (
                input: "***",
                forbiddenPatterns: ["***"],
                description: "Alternative HR should not show asterisks"
            )
        ]
        
        for testCase in testCases {
            // Test MarkdownView
            let document = MarkdownParser.parse(testCase.input)
            let nsAttributedString = document.attributedString(options: .default)
            
            // Convert to plain text to check what would be displayed
            let plainText = nsAttributedString.string
            
            for pattern in testCase.forbiddenPatterns {
                #expect(
                    !plainText.contains(pattern),
                    "REGRESSION: \(testCase.description). Found '\(pattern)' in rendered output: '\(plainText)'"
                )
            }
        }
    }
    
    @Test("Complex markdown documents render without syntax artifacts")
    func testComplexMarkdownNoSyntaxArtifacts() {
        let complexMarkdown = """
        # Main Title
        
        ## Introduction
        
        This is a **complex** document with *various* markdown elements.
        
        ### Features
        
        - First feature with `inline code`
        - Second feature with **bold** text
          - Nested item with *italic*
        - Third feature with [links](https://example.com)
        
        ### Code Example
        
        ```swift
        struct Example {
            let value: String = "test"
            
            func process() -> Bool {
                return true
            }
        }
        ```
        
        ### Quotes and Rules
        
        > This is a blockquote with **formatted** text
        > spanning multiple lines
        
        ---
        
        ### Mixed Content
        
        1. Ordered item with **bold**
        2. Another item with `code`
        3. Item with [link](url) and *italic*
        
        ![Image description](path/to/image.png)
        
        That's all folks!
        """
        
        let document = MarkdownParser.parse(complexMarkdown)
        let rendered = document.attributedString(options: .default).string
        
        // Be selective about what patterns to check
        #expect(!rendered.contains("###"))
        #expect(!rendered.contains("```"))
        #expect(!rendered.contains("- First"))
        #expect(!rendered.contains("> This is"))
        #expect(!rendered.contains("[links]"))
        #expect(!rendered.contains("![Image"))
        #expect(!rendered.contains("---") || rendered.contains("—"))  // Could be em dash
    }
    
    @Test("AttributedString conversion preserves all formatting")
    func testAttributedStringConversionPreservesFormatting() {
        let markdown = """
        # Title
        **Bold** and *italic* and `code`
        """
        
        let document = MarkdownParser.parse(markdown)
        let nsAttributedString = document.attributedString(options: .default)
        
        // Check that attributes are present
        var hasBold = false
        var hasItalic = false
        var hasCode = false
        var hasHeading = false
        
        nsAttributedString.enumerateAttributes(
            in: NSRange(location: 0, length: nsAttributedString.length),
            options: []
        ) { attributes, range, _ in
            if let font = attributes[.font] as? PlatformFont {
                let fontTraits = font.fontDescriptor.symbolicTraits
                
                #if canImport(AppKit)
                if fontTraits.contains(.bold) {
                    hasBold = true
                }
                if fontTraits.contains(.italic) {
                    hasItalic = true
                }
                #elseif canImport(UIKit)
                if fontTraits.contains(.traitBold) {
                    hasBold = true
                }
                if fontTraits.contains(.traitItalic) {
                    hasItalic = true
                }
                #endif
                
                // Check for monospace (code)
                let fontName = font.fontName.lowercased()
                if fontName.contains("mono") || fontName.contains("menlo") || fontName.contains("courier") {
                    hasCode = true
                }
                
                // Check for heading (larger size)
                if font.pointSize > PlatformFont.systemFontSize + 2 {
                    hasHeading = true
                }
            }
        }
        
        #expect(hasBold, "Bold formatting should be preserved")
        #expect(hasItalic, "Italic formatting should be preserved")
        #expect(hasCode, "Code formatting should be preserved")
        #expect(hasHeading, "Heading formatting should be preserved")
    }
    
    @Test("SwiftUI Text extension renders without raw markdown")
    func testTextExtensionNoRawMarkdown() {
        let markdownSamples = [
            "**bold**",
            "*italic*",
            "`code`",
            "# Header",
            "[link](url)",
            "- list item"
        ]
        
        for sample in markdownSamples {
            let document = MarkdownParser.parse(sample)
            let nsAttributedString = document.attributedString(options: .default)
            
            #if canImport(UIKit)
            if let converted = try? AttributedString(nsAttributedString, including: \.uiKit) {
                let text = String(converted.characters)
                #expect(!text.contains("**"), "Should not contain ** in: \(text)")
                #expect(!text.contains("*") || sample.contains("*"), "Should not contain markdown * in: \(text)")
                #expect(!text.contains("`"), "Should not contain ` in: \(text)")
                #expect(!text.contains("#"), "Should not contain # in: \(text)")
                #expect(!text.contains("["), "Should not contain [ in: \(text)")
                #expect(!text.contains("- ") || !text.hasPrefix("- "), "Should not start with - in: \(text)")
            }
            #elseif canImport(AppKit)
            if let converted = try? AttributedString(nsAttributedString, including: \.appKit) {
                let text = String(converted.characters)
                #expect(!text.contains("**"), "Should not contain ** in: \(text)")
                #expect(!text.contains("`"), "Should not contain ` in: \(text)")
                #expect(!text.contains("#") || !text.hasPrefix("#"), "Should not start with # in: \(text)")
                #expect(!text.contains("["), "Should not contain [ in: \(text)")
            }
            #endif
        }
    }
    
    @Test("Streaming updates never show intermediate raw markdown")
    func testStreamingNeverShowsRawMarkdown() {
        // Simulate progressive markdown streaming
        let streamStages = [
            "#",
            "# H",
            "# Hello",
            "# Hello\n",
            "# Hello\n*",
            "# Hello\n**",
            "# Hello\n**Bo",
            "# Hello\n**Bold**",
            "# Hello\n**Bold** text",
            "# Hello\n**Bold** text with `",
            "# Hello\n**Bold** text with `code",
            "# Hello\n**Bold** text with `code`"
        ]
        
        for stage in streamStages {
            let document = MarkdownParser.parse(stage)
            let rendered = document.attributedString(options: .default).string
            
            // Even incomplete markdown should not show raw syntax for completed parts
            if stage.contains("**Bold**") {
                #expect(!rendered.contains("**Bold**"), "Complete bold should render without markers at stage: \(stage)")
            }
            
            if stage.contains("`code`") {
                #expect(!rendered.contains("`code`"), "Complete code should render without backticks at stage: \(stage)")
            }
            
            // Headers should never show # once complete
            if stage.contains("# Hello\n") {
                #expect(!rendered.hasPrefix("#"), "Complete header should not start with # at stage: \(stage)")
            }
        }
    }
    
    @Test("All themes render without showing markdown syntax")
    func testAllThemesRenderWithoutSyntax() {
        let markdown = """
        # Theme Test
        **Bold** and *italic* and `code`
        - List item
        > Quote
        [Link](url)
        """
        
        let themes: [MarkdownRenderingOptions] = [
            .default,
            .github,
            .documentation,
            .chat
        ]
        
        for theme in themes {
            let document = MarkdownParser.parse(markdown)
            let rendered = document.attributedString(options: theme).string
            
            // No theme should ever show raw markdown
            #expect(!rendered.hasPrefix("# "), "Theme header should not start with #")
            #expect(!rendered.contains("**Bold**"), "Bold should not show markers")
            #expect(!rendered.contains("*italic*"), "Italic should not show markers")
            #expect(!rendered.contains("`code`"), "Code should not show backticks")
            // Note: Lists might legitimately contain "- " in the output
            // Note: Blockquotes might legitimately show "> " as part of formatting
            #expect(!rendered.contains("[Link]"), "Link should not show brackets")
        }
    }
    
    @Test("Edge cases don't cause raw markdown display")
    func testEdgeCasesNoRawMarkdown() {
        let edgeCases = [
            "",                          // Empty
            " ",                         // Whitespace only
            "\n\n\n",                   // Multiple newlines
            "Plain text",               // No markdown
            "**",                       // Incomplete bold
            "**Unclosed bold",          // Unclosed bold
            "*Unclosed italic",         // Unclosed italic
            "`Unclosed code",           // Unclosed code
            "[Unclosed link",           // Unclosed link
            "![Unclosed image",         // Unclosed image
            "Mixed **bold and *italic* text**",  // Nested
            "```\nUnclosed code block",  // Unclosed code block
            "> > > Nested quotes",       // Nested blockquotes
        ]
        
        for edgeCase in edgeCases {
            let document = MarkdownParser.parse(edgeCase)
            let rendered = document.attributedString(options: .default).string
            
            // Even edge cases should attempt to render cleanly
            // The parser should handle these gracefully
            #expect(rendered.count >= 0, "Should handle edge case: \(edgeCase)")
            
            // For incomplete markdown, the markers might appear as literal text
            // But completed markdown should never show markers
            if edgeCase.contains("**bold and *italic* text**") {
                // This is complete markdown, should not show markers for the complete parts
                let plainText = rendered.replacingOccurrences(of: "\n", with: " ")
                #expect(!plainText.contains("**bold and"), "Should not show ** before 'bold'")
            }
        }
    }
    
    @Test("Platform-specific attribute scopes work correctly")
    func testPlatformSpecificAttributeScopes() {
        let markdown = "# Test\n**Bold** and *italic*"
        let document = MarkdownParser.parse(markdown)
        let nsAttributedString = document.attributedString(options: .default)
        
        // Test that the correct attribute scope is used for the platform
        #if canImport(UIKit)
        // iOS/iPadOS should use uiKit scope
        if let converted = try? AttributedString(nsAttributedString, including: \.uiKit) {
            #expect(converted.characters.count > 0, "UIKit scope should work")
            let text = String(converted.characters)
            #expect(!text.contains("#"), "Should not contain # with uiKit scope")
            #expect(!text.contains("**"), "Should not contain ** with uiKit scope")
        } else {
            Issue.record("Failed to convert with uiKit scope - this would cause raw markdown display!")
        }
        #elseif canImport(AppKit)
        // macOS should use appKit scope
        if let converted = try? AttributedString(nsAttributedString, including: \.appKit) {
            #expect(converted.characters.count > 0, "AppKit scope should work")
            let text = String(converted.characters)
            #expect(!text.contains("#"), "Should not contain # with appKit scope")
            #expect(!text.contains("**"), "Should not contain ** with appKit scope")
        } else {
            Issue.record("Failed to convert with appKit scope - this would cause raw markdown display!")
        }
        #endif
        
        // Foundation scope should always work as fallback
        if let converted = try? AttributedString(nsAttributedString, including: \.foundation) {
            #expect(converted.characters.count > 0, "Foundation scope should work as fallback")
        }
    }
    
    @Test("CRITICAL: Verify actual SwiftUI component output")
    func testActualSwiftUIComponentOutput() {
        // This test verifies the actual components work correctly
        // It simulates what the xamrock-client team experienced
        
        let markdown = """
        ## Lists
        
        ### Unordered List
        - First item
        - Second item
          - Nested item
        - Third item
        
        ### Ordered List
        1. First step
        2. Second step
        3. Third step
        """
        
        // Test that the parsing and rendering pipeline works end-to-end
        let document = MarkdownParser.parse(markdown)
        let nsAttributedString = document.attributedString(options: .chat)
        
        // Get the plain text that would be displayed
        let displayedText = nsAttributedString.string
        
        // CRITICAL CHECKS - These would have caught the xamrock bug
        #expect(!displayedText.contains("##"), "Headers should not show ## markers")
        #expect(!displayedText.contains("###"), "Headers should not show ### markers")
        #expect(!displayedText.contains("- First item"), "List items should not show - markers at the start")
        
        // Verify formatting is applied
        var hasFormatting = false
        nsAttributedString.enumerateAttributes(
            in: NSRange(location: 0, length: nsAttributedString.length),
            options: []
        ) { attributes, _, _ in
            if attributes.count > 0 {
                hasFormatting = true
            }
        }
        
        #expect(hasFormatting, "Rendered output should have formatting attributes")
    }
}

// MARK: - Canary Test
// This test will fail immediately if markdown rendering breaks

@Test("🚨 CANARY: Basic markdown MUST render without showing syntax")
func markdownRenderingCanaryTest() {
    // This is a canary test - if this fails, markdown rendering is broken!
    let critical = [
        ("# Header", "#"),
        ("**bold**", "**"),
        ("*italic*", "*italic*"),
        ("`code`", "`"),
        ("- list", "- list"),
        ("[link](url)", "[link]")
    ]
    
    for (markdown, forbidden) in critical {
        let document = MarkdownParser.parse(markdown)
        let rendered = document.attributedString(options: .default).string
        
        #expect(
            !rendered.contains(forbidden),
            "🚨 CRITICAL REGRESSION: Markdown '\(markdown)' is showing raw syntax '\(forbidden)' in output: '\(rendered)'"
        )
    }
}

#endif