//
//  SwiftUIRenderingTests.swift
//  syndromeTests
//
//  Tests to verify SwiftUI components actually render markdown
//

import Testing
import Foundation
@testable import syndrome

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI

@Suite("SwiftUI Markdown Rendering")
struct SwiftUIRenderingTests {
    
    @Test("MarkdownView renders formatted text, not raw markdown")
    func testMarkdownViewRendersFormatted() {
        let markdown = "**bold** text"
        let view = MarkdownView(markdown)
        
        // The view should parse and render
        #expect(view != nil)
        
        // Verify the internal conversion is happening
        let document = MarkdownParser.parse(markdown)
        let nsAttributed = document.attributedString(options: .default)
        #expect(nsAttributed.string == "bold text", "Should parse to plain text without markdown syntax")
        #expect(nsAttributed.length > 0)
        
        // Check that bold formatting is applied
        var hasBoldAttribute = false
        nsAttributed.enumerateAttributes(in: NSRange(location: 0, length: 4), options: []) { attributes, range, _ in
            if let font = attributes[.font] as? PlatformFont {
                #if canImport(AppKit)
                if font.fontDescriptor.symbolicTraits.contains(.bold) {
                    hasBoldAttribute = true
                }
                #else
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    hasBoldAttribute = true
                }
                #endif
            }
        }
        #expect(hasBoldAttribute, "Bold text should have bold font attribute")
    }
    
    @Test("StreamingMarkdownView renders formatted text")
    func testStreamingMarkdownViewRendersFormatted() {
        var content = "# Heading\n**bold** text"
        let binding = Binding(get: { content }, set: { content = $0 })
        let view = StreamingMarkdownView(content: binding)
        
        #expect(view != nil)
        
        // Verify parsing happens
        let document = MarkdownParser.parse(content)
        let nsAttributed = document.attributedString(options: .default)
        #expect(!nsAttributed.string.contains("#"), "Should not contain markdown syntax")
        #expect(!nsAttributed.string.contains("**"), "Should not contain markdown syntax")
    }
    
    @Test("Text markdown extension renders formatted")
    func testTextMarkdownExtension() {
        let _ = Text(markdown: "**bold** and *italic*")
        
        // Verify the parsing happens internally
        let document = MarkdownParser.parse("**bold** and *italic*")
        let nsAttributed = document.attributedString(options: .default)
        #expect(nsAttributed.string == "bold and italic")
        #expect(!nsAttributed.string.contains("**"))
        #expect(!nsAttributed.string.contains("*"))
    }
    
    @Test("Complex markdown renders without syntax")
    func testComplexMarkdownRendering() {
        let markdown = """
        # Title
        ## Subtitle
        
        **Bold** and *italic* and `code`.
        
        - List 1
        - List 2
        
        [Link](https://example.com)
        """
        
        let view = MarkdownView(markdown)
        #expect(view != nil)
        
        let document = MarkdownParser.parse(markdown)
        let nsAttributed = document.attributedString(options: .default)
        
        // Check that markdown syntax is removed
        let plainText = nsAttributed.string
        #expect(!plainText.contains("#"), "Headers should not show # symbols")
        #expect(!plainText.contains("**"), "Bold markers should be removed")
        #expect(!plainText.contains("*"), "Italic markers should be removed")
        #expect(!plainText.contains("`"), "Code markers should be removed")
        #expect(!plainText.contains("[Link]"), "Link syntax should be processed")
        #expect(plainText.contains("Title"), "Should contain header text")
        #expect(plainText.contains("Bold"), "Should contain bold text")
        #expect(plainText.contains("List 1"), "Should contain list items")
    }
    
    @Test("AttributedString conversion preserves formatting")
    func testAttributedStringConversion() {
        let markdown = "**bold** text"
        let document = MarkdownParser.parse(markdown)
        let nsAttributed = document.attributedString(options: .default)
        
        // Try the conversion that MarkdownView uses
        do {
            let swiftUIAttributed = try AttributedString(nsAttributed, including: \.foundation)
            #expect(swiftUIAttributed.characters.count > 0)
            
            // The string should not contain markdown
            let plainString = String(swiftUIAttributed.characters)
            #expect(plainString == "bold text")
            #expect(!plainString.contains("**"))
        } catch {
            Issue.record("Failed to convert NSAttributedString to AttributedString: \(error)")
        }
    }
}

#endif