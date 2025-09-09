//
//  MarkdownCanaryTests.swift
//  syndromeTests
//
//  Canary tests that will fail IMMEDIATELY if markdown rendering breaks
//  These are the most critical tests - if any fail, users see raw markdown
//

import Testing
import Foundation
@testable import syndrome

#if canImport(UIKit) || canImport(AppKit)

@Suite("🚨 Markdown Rendering Canary Tests")
struct MarkdownCanaryTests {
    
    @Test("🚨 Headers MUST NOT show # symbols")
    func canaryTestHeaders() {
        let tests = [
            "# H1",
            "## H2", 
            "### H3",
            "#### H4",
            "##### H5",
            "###### H6"
        ]
        
        for markdown in tests {
            let document = MarkdownParser.parse(markdown)
            let rendered = document.attributedString(options: .default).string
            
            #expect(
                !rendered.hasPrefix("#"),
                "🚨 CRITICAL: Header '\(markdown)' showing raw # in output: '\(rendered)'"
            )
        }
    }
    
    @Test("🚨 Bold text MUST NOT show ** or __ markers")
    func canaryTestBold() {
        let tests = [
            "**bold**",
            "__bold__",
            "**multiple words**",
            "__multiple words__"
        ]
        
        for markdown in tests {
            let document = MarkdownParser.parse(markdown)
            let rendered = document.attributedString(options: .default).string
            
            #expect(
                !rendered.contains("**") && !rendered.contains("__"),
                "🚨 CRITICAL: Bold '\(markdown)' showing raw markers in output: '\(rendered)'"
            )
        }
    }
    
    @Test("🚨 Italic text MUST NOT show * or _ markers around words")
    func canaryTestItalic() {
        let tests = [
            "*italic*",
            "_italic_",
            "*multiple words*",
            "_multiple words_"
        ]
        
        for markdown in tests {
            let document = MarkdownParser.parse(markdown)
            let rendered = document.attributedString(options: .default).string
            
            // Check for the specific pattern of markers around the text
            #expect(
                !rendered.contains("*italic*") && !rendered.contains("_italic_") &&
                !rendered.contains("*multiple words*") && !rendered.contains("_multiple words_"),
                "🚨 CRITICAL: Italic '\(markdown)' showing raw markers in output: '\(rendered)'"
            )
        }
    }
    
    @Test("🚨 Code MUST NOT show backticks")
    func canaryTestCode() {
        let tests = [
            "`code`",
            "`multiple words`",
            "```\ncode block\n```",
            "```swift\nfunc test() {}\n```"
        ]
        
        for markdown in tests {
            let document = MarkdownParser.parse(markdown)
            let rendered = document.attributedString(options: .default).string
            
            #expect(
                !rendered.contains("`"),
                "🚨 CRITICAL: Code '\(markdown)' showing backticks in output: '\(rendered)'"
            )
        }
    }
    
    @Test("🚨 Links MUST NOT show [brackets] or (urls)")  
    func canaryTestLinks() {
        let tests = [
            "[link](url)",
            "[Google](https://google.com)",
            "[text with spaces](https://example.com)"
        ]
        
        for markdown in tests {
            let document = MarkdownParser.parse(markdown)
            let rendered = document.attributedString(options: .default).string
            
            #expect(
                !rendered.contains("[") && !rendered.contains("]"),
                "🚨 CRITICAL: Link '\(markdown)' showing brackets in output: '\(rendered)'"
            )
            
            // URLs in parentheses should not appear
            #expect(
                !rendered.contains("(http") && !rendered.contains("(url)"),
                "🚨 CRITICAL: Link '\(markdown)' showing URL in parentheses in output: '\(rendered)'"
            )
        }
    }
    
    @Test("🚨 Master canary - Common markdown patterns")
    func masterCanaryTest() {
        // This is THE test that would have caught the xamrock issue
        let markdown = """
        # Title
        
        This is **bold** and *italic* text.
        
        - List item
        
        `code here`
        
        [Link](https://example.com)
        """
        
        let document = MarkdownParser.parse(markdown)
        let rendered = document.attributedString(options: .default).string
        
        // These patterns should NEVER appear in rendered output
        let forbidden = [
            "# Title",      // Raw header
            "**bold**",     // Raw bold
            "*italic*",     // Raw italic
            "`code here`",  // Raw code
            "[Link]"        // Raw link syntax
        ]
        
        for pattern in forbidden {
            #expect(
                !rendered.contains(pattern),
                """
                🚨 CRITICAL FAILURE: Markdown is not being rendered!
                Pattern '\(pattern)' found in output.
                This means users are seeing raw markdown syntax.
                Full output: '\(rendered)'
                """
            )
        }
        
        // Also verify that the text content IS present (just without markers)
        #expect(rendered.contains("Title"), "Title text should be present")
        #expect(rendered.contains("bold"), "Bold text should be present")
        #expect(rendered.contains("italic"), "Italic text should be present")
        #expect(rendered.contains("code here"), "Code text should be present")
        #expect(rendered.contains("Link"), "Link text should be present")
    }
    
    @Test("🚨 SwiftUI component integration canary")
    func swiftUIComponentCanary() {
        // Test the exact scenario from the xamrock bug report
        let markdown = """
        ## Lists
        
        ### Unordered List
        - First item
        - Second item
        
        ### Ordered List
        1. First step
        2. Second step
        """
        
        let document = MarkdownParser.parse(markdown)
        
        // Test with all themes to ensure none break
        let themes: [MarkdownRenderingOptions] = [.default, .github, .documentation, .chat]
        
        for theme in themes {
            let rendered = document.attributedString(options: theme).string
            
            // The critical check - headers should NEVER show ## or ###
            #expect(
                !rendered.contains("##") && !rendered.contains("###"),
                """
                🚨 XAMROCK BUG DETECTED: Headers showing raw markdown!
                Theme: \(theme)
                Output contains ## or ### symbols.
                This is the exact bug that was reported.
                Full output: '\(rendered)'
                """
            )
            
            // Verify content is present
            #expect(rendered.contains("Lists"), "Content should be present")
            #expect(rendered.contains("Unordered"), "Content should be present")
            #expect(rendered.contains("First"), "Content should be present")
        }
    }
}

#endif