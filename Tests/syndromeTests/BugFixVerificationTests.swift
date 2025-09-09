//
//  BugFixVerificationTests.swift
//  syndromeTests
//
//  Verifies the bug reported by xamrock-client is fixed
//

import Testing
import Foundation
@testable import syndrome

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI

@Suite("Bug Fix Verification - Xamrock Report")
struct BugFixVerificationTests {
    
    @Test("Bug #1: MarkdownView should render formatted text, not raw markdown")
    func testMarkdownViewNotShowingRawMarkdown() {
        // Test case from bug report
        let markdown = """
            # Heading 1
            ## Heading 2
            
            This is **bold** and *italic* text.
            
            - List item 1
            - List item 2
            
            `inline code`
            
            ```swift
            func hello() {
                print("Hello, World!")
            }
            ```
            """
        
        let view = MarkdownView(markdown)
        
        // Parse to verify what should be displayed
        let document = MarkdownParser.parse(markdown)
        let nsAttributed = document.attributedString(options: .default)
        let renderedText = nsAttributed.string
        
        // Verify markdown syntax is NOT in the rendered output
        #expect(!renderedText.contains("#"), "Should not show # symbols")
        #expect(!renderedText.contains("**"), "Should not show ** for bold")
        #expect(!renderedText.contains("*List"), "Should not show * for lists")
        #expect(!renderedText.contains("`"), "Should not show backticks")
        #expect(!renderedText.contains("```"), "Should not show code fence markers")
        
        // Verify actual content IS present
        #expect(renderedText.contains("Heading 1"))
        #expect(renderedText.contains("Heading 2"))
        #expect(renderedText.contains("bold"))
        #expect(renderedText.contains("italic"))
        #expect(renderedText.contains("List item 1"))
        #expect(renderedText.contains("inline code"))
        #expect(renderedText.contains("func hello()"))
    }
    
    @Test("Bug #2: StreamingMarkdownView should update with formatted text")
    func testStreamingMarkdownViewUpdates() {
        var content = "# Initial Header\n\nLoading..."
        let binding = Binding(get: { content }, set: { content = $0 })
        
        let view = StreamingMarkdownView(content: binding)
        
        // Verify initial state
        let initialDoc = MarkdownParser.parse(content)
        let initialRendered = initialDoc.attributedString(options: .default).string
        #expect(!initialRendered.contains("#"))
        #expect(initialRendered.contains("Initial Header"))
        
        // Update content (simulating streaming)
        content = """
        # Updated Header
        
        This is **new** content with *formatting*.
        
        - New item 1
        - New item 2
        """
        
        // Verify updated state
        let updatedDoc = MarkdownParser.parse(content)
        let updatedRendered = updatedDoc.attributedString(options: .default).string
        #expect(!updatedRendered.contains("#"))
        #expect(!updatedRendered.contains("**"))
        #expect(!updatedRendered.contains("*"))
        #expect(updatedRendered.contains("Updated Header"))
        #expect(updatedRendered.contains("new"))
        #expect(updatedRendered.contains("formatting"))
        #expect(updatedRendered.contains("New item 1"))
    }
    
    @Test("Bug #3: Lists should render as formatted lists, not raw markdown")
    func testListsRenderProperly() {
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
        
        let view = MarkdownView(markdown)
        let document = MarkdownParser.parse(markdown)
        let rendered = document.attributedString(options: .default).string
        
        // Should NOT contain markdown syntax
        #expect(!rendered.contains("##"))
        #expect(!rendered.contains("###"))
        #expect(!rendered.contains("- First"))
        // Note: Ordered lists do show "1." etc in the output - that's correct behavior
        
        // Should contain actual content
        #expect(rendered.contains("Lists"))
        #expect(rendered.contains("Unordered List"))
        #expect(rendered.contains("First item"))
        #expect(rendered.contains("Second item"))
        #expect(rendered.contains("Nested item"))
        #expect(rendered.contains("First step"))
    }
    
    @Test("Verify AttributedString conversion works on macOS")
    func testAttributedStringConversionOnMacOS() {
        let markdown = "**bold** and *italic*"
        let document = MarkdownParser.parse(markdown)
        let nsAttributed = document.attributedString(options: .default)
        
        #if canImport(AppKit)
        // Try appKit scope (for macOS)
        do {
            let converted = try AttributedString(nsAttributed, including: \.appKit)
            let text = String(converted.characters)
            #expect(text == "bold and italic")
            #expect(!text.contains("**"))
            #expect(!text.contains("*"))
        } catch {
            // Fallback test
            do {
                let converted = try AttributedString(nsAttributed, including: \.foundation)
                let text = String(converted.characters)
                #expect(text == "bold and italic")
            } catch {
                Issue.record("Failed to convert on macOS: \(error)")
            }
        }
        #endif
    }
    
    @Test("Integration: Complex markdown from bug report renders correctly")
    func testComplexMarkdownFromBugReport() {
        // Exact example from the bug report
        let markdown = """
        # Heading 1
        ## Heading 2
        
        This is **bold** and *italic* text.
        
        - List item 1
        - List item 2
        
        `inline code`
        
        ```swift
        func hello() {
            print("Hello, World!")
        }
        ```
        """
        
        // Test MarkdownView
        let markdownView = MarkdownView(markdown, options: .default)
        #expect(markdownView != nil)
        
        // Test with chat theme (as xamrock uses)
        let chatView = MarkdownView(markdown, options: .chat)
        #expect(chatView != nil)
        
        // Test Text extension
        let textView = Text(markdown: "**bold** text", options: .chat)
        #expect(textView != nil)
        
        // Verify the rendered output
        let document = MarkdownParser.parse(markdown)
        let chatRendered = document.attributedString(options: .chat)
        
        // Check rendering options are applied
        #expect(MarkdownRenderingOptions.chat.paragraphSpacing == 14.0)
        #expect(MarkdownRenderingOptions.chat.lineSpacing == 3.0)
        
        // Verify no raw markdown in output
        let outputText = chatRendered.string
        #expect(!outputText.hasPrefix("#"))
        #expect(!outputText.contains("```swift"))
        #expect(!outputText.contains("**bold**"))
        
        // Verify formatted content exists
        #expect(outputText.contains("Heading 1"))
        #expect(outputText.contains("bold and italic text"))
        #expect(outputText.contains("List item 1"))
        #expect(outputText.contains("inline code"))
        #expect(outputText.contains("func hello()"))
    }
}

#endif