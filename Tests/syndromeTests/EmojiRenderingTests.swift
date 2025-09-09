//
//  EmojiRenderingTests.swift
//  syndromeTests
//
//  Tests for emoji rendering support as requested by xamrock-client
//

import Testing
import Foundation
@testable import syndrome

@Suite("Emoji Rendering Tests")
struct EmojiRenderingTests {
    
    @Test("Parse emojis in text")
    func testParseEmojisInText() {
        let markdown = "Hello 🎉 World 🌤️ with emojis 💻"
        let document = MarkdownParser.parse(markdown)
        
        #expect(document.blocks.count == 1)
        
        guard case .paragraph(let content) = document.blocks[0] else {
            Issue.record("Expected paragraph block")
            return
        }
        
        guard case .text(let text) = content[0] else {
            Issue.record("Expected text element")
            return
        }
        
        // Verify emojis are preserved in the parsed text
        #expect(text.contains("🎉"))
        #expect(text.contains("🌤️"))
        #expect(text.contains("💻"))
        #expect(text == "Hello 🎉 World 🌤️ with emojis 💻")
    }
    
    @Test("Parse emojis in headers")
    func testParseEmojisInHeaders() {
        let testCases = [
            "# Header with 🎉 emoji",
            "## 📊 Data Analysis",
            "### 💻 Development Section",
            "#### ✅ Completed Tasks",
            "##### 📁 File Operations",
            "###### 🌤️ Weather Info"
        ]
        
        for markdown in testCases {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            
            guard case .heading(_, let content) = document.blocks[0] else {
                Issue.record("Expected heading block for: \(markdown)")
                continue
            }
            
            guard case .text(let text) = content[0] else {
                Issue.record("Expected text element in heading")
                continue
            }
            
            // Check that at least one emoji is preserved
            let hasEmoji = text.contains("🎉") || text.contains("📊") || 
                          text.contains("💻") || text.contains("✅") || 
                          text.contains("📁") || text.contains("🌤️")
            #expect(hasEmoji, "Emoji should be preserved in: \(text)")
        }
    }
    
    @Test("Parse emojis in lists")
    func testParseEmojisInLists() {
        let markdown = """
        - Item with ✅ checkmark
        - Item with 📊 chart
        - Item with 💻 computer
        """
        
        let document = MarkdownParser.parse(markdown)
        
        #expect(document.blocks.count == 1)
        
        guard case .list(let items, _) = document.blocks[0] else {
            Issue.record("Expected list block")
            return
        }
        
        #expect(items.count == 3)
        
        let expectedEmojis = ["✅", "📊", "💻"]
        for (index, item) in items.enumerated() {
            guard case .paragraph(let content) = item.content[0],
                  case .text(let text) = content[0] else {
                Issue.record("Expected text in list item \(index)")
                continue
            }
            
            #expect(text.contains(expectedEmojis[index]), 
                   "List item \(index) should contain emoji \(expectedEmojis[index])")
        }
    }
    
    @Test("Parse emojis in bold and italic")
    func testParseEmojisInEmphasis() {
        let testCases = [
            ("**Bold with 🎉 emoji**", "Bold with 🎉 emoji"),
            ("*Italic with 📊 chart*", "Italic with 📊 chart"),
            ("**Bold with *nested italic* 💻**", "Bold with nested italic 💻")
        ]
        
        for (markdown, expectedText) in testCases {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph for: \(markdown)")
                continue
            }
            
            // Extract text from emphasis elements
            var extractedText = ""
            for element in content {
                extractedText += extractText(from: element)
            }
            
            #expect(extractedText == expectedText, 
                   "Extracted '\(extractedText)' should equal '\(expectedText)'")
        }
    }
    
    @Test("Parse emojis in links")
    func testParseEmojisInLinks() {
        let markdown = "[Click 🎉 here](https://example.com)"
        let document = MarkdownParser.parse(markdown)
        
        #expect(document.blocks.count == 1)
        
        guard case .paragraph(let content) = document.blocks[0] else {
            Issue.record("Expected paragraph")
            return
        }
        
        guard case .link(let linkText, _, _) = content[0] else {
            Issue.record("Expected link element")
            return
        }
        
        guard case .text(let text) = linkText[0] else {
            Issue.record("Expected text in link")
            return
        }
        
        #expect(text == "Click 🎉 here")
    }
    
    @Test("Parse mixed emoji types")
    func testParseMixedEmojiTypes() {
        let markdown = """
        # Title with 🎉 celebration emoji
        
        Paragraph with various emojis: 😀 😃 😄 😁 😆 😅 😂 🤣
        
        **Bold with flags:** 🇺🇸 🇬🇧 🇯🇵 🇩🇪 🇫🇷
        
        - Item with hand gestures: 👍 👎 👌 ✌️ 🤞
        - Item with objects: 📱 💻 ⌚️ 📷 🎮
        - Item with nature: 🌸 🌺 🌻 🌷 🌹
        """
        
        let document = MarkdownParser.parse(markdown)
        
        // Just verify parsing doesn't fail and structure is preserved
        #expect(document.blocks.count >= 3, "Should have at least 3 blocks")
        
        // Verify first block is heading with emoji
        guard case .heading(_, let headingContent) = document.blocks[0],
              case .text(let headingText) = headingContent[0] else {
            Issue.record("Expected heading with text")
            return
        }
        
        #expect(headingText.contains("🎉"))
    }
    
    #if canImport(AppKit) || canImport(UIKit)
    @Test("Render emojis to attributed string")
    func testRenderEmojisToAttributedString() {
        let markdown = "Hello 🎉 World with **bold 📊 emoji** and *italic 💻 emoji*"
        let document = MarkdownParser.parse(markdown)
        
        let renderer = MarkdownRenderer()
        let attributed = renderer.render(document)
        
        // Verify the attributed string contains the emojis
        let plainString = attributed.string
        #expect(plainString.contains("🎉"))
        #expect(plainString.contains("📊"))
        #expect(plainString.contains("💻"))
        
        // Verify length is reasonable (emojis should not be expanded to escape sequences)
        #expect(attributed.length > 0)
        #expect(attributed.length < 100, "String length should be reasonable, not expanded")
    }
    
    @Test("Render emoji headers with proper styling")
    func testRenderEmojiHeadersWithStyling() {
        let markdown = "# 🎉 Celebration Header"
        let document = MarkdownParser.parse(markdown)
        
        let renderer = MarkdownRenderer(options: .github)
        let attributed = renderer.render(document)
        
        // Verify emoji is in the rendered output
        #expect(attributed.string.contains("🎉"))
        
        // Verify header has larger font
        var hasLargerFont = false
        attributed.enumerateAttribute(.font, in: NSRange(location: 0, length: attributed.length)) { value, range, _ in
            if let font = value as? PlatformFont {
                // Headers should have font size > base font size
                hasLargerFont = font.pointSize > 16 // GitHub theme base is 16
            }
        }
        #expect(hasLargerFont, "Header should have larger font")
    }
    
    @Test("Render emojis with different themes")
    func testRenderEmojisWithDifferentThemes() {
        let markdown = "Test 🎉 emoji rendering"
        let document = MarkdownParser.parse(markdown)
        
        let themes: [MarkdownRenderingOptions] = [.default, .github, .documentation, .chat]
        
        for theme in themes {
            let renderer = MarkdownRenderer(options: theme)
            let attributed = renderer.render(document)
            
            #expect(attributed.string.contains("🎉"), 
                   "Emoji should be preserved in all themes")
        }
    }
    #endif
    
    // Helper function to extract text from inline elements
    private func extractText(from element: InlineElement) -> String {
        switch element {
        case .text(let str):
            return str
        case .emphasis(let content), .strongEmphasis(let content):
            return content.map { extractText(from: $0) }.joined()
        case .code(let str):
            return str
        case .link(let text, _, _):
            return text.map { extractText(from: $0) }.joined()
        case .image(let alt, _, _):
            return alt.map { extractText(from: $0) }.joined()
        case .softBreak:
            return " "
        case .hardBreak:
            return "\n"
        case .htmlInline(let str):
            return str
        }
    }
}