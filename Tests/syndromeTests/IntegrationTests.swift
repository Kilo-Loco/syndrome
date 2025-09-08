import Testing
import Foundation
@testable import syndrome

@Suite("Integration Tests")
struct IntegrationTests {
    
    @Test("Parser migration maintains all features")
    func testParserMigrationMaintainsAllFeatures() {
        // Test headings
        let heading = MarkdownParser.parse("# Heading 1\n## Heading 2")
        #expect(heading.blocks.count == 2)
        
        // Test paragraphs
        let paragraph = MarkdownParser.parse("This is a paragraph.")
        #expect(paragraph.blocks.count == 1)
        
        // Test lists
        let list = MarkdownParser.parse("- Item 1\n- Item 2")
        #expect(list.blocks.count == 1)
        
        // Test code blocks
        let codeBlock = MarkdownParser.parse("```swift\nlet x = 1\n```")
        #expect(codeBlock.blocks.count == 1)
        
        // Test blockquotes
        let blockquote = MarkdownParser.parse("> Quote")
        #expect(blockquote.blocks.count == 1)
    }
    
    @Test("Backslash escape handling works")
    func testBackslashEscapeHandling() {
        let escaped = MarkdownParser.parse("\\*not italic\\*")
        if case let .paragraph(content) = escaped.blocks.first {
            var text = ""
            for element in content {
                if case let .text(str) = element {
                    text += str
                }
            }
            #expect(text.contains("*"))
        } else {
            Issue.record("Expected paragraph with escaped asterisks")
        }
    }
    
    @Test("HTML entity processing works")
    func testHTMLEntityProcessing() {
        let entities = MarkdownParser.parse("&copy; &amp; &lt;test&gt;")
        if case let .paragraph(content) = entities.blocks.first {
            var text = ""
            for element in content {
                if case let .text(str) = element {
                    text += str
                }
            }
            #expect(text.contains("©"))
            #expect(text.contains("&"))
            #expect(text.contains("<"))
            #expect(text.contains(">"))
        } else {
            Issue.record("Expected paragraph with HTML entities")
        }
    }
    
    @Test("Tab expansion functionality works")
    func testTabExpansionFunctionality() {
        let tabs = MarkdownParser.parse("-\tList item with tab")
        #expect(tabs.blocks.count == 1)
        if case let .list(items, _) = tabs.blocks.first {
            #expect(items.count == 1)
        } else {
            Issue.record("Expected list with tab-indented item")
        }
    }
    
    @Test("Inline elements are parsed correctly")
    func testInlineElements() {
        // Bold
        let bold = MarkdownParser.parse("**bold text**")
        if case let .paragraph(content) = bold.blocks.first,
           case .strongEmphasis = content.first {
            #expect(true)
        } else {
            Issue.record("Failed to parse bold text")
        }
        
        // Italic
        let italic = MarkdownParser.parse("*italic text*")
        if case let .paragraph(content) = italic.blocks.first,
           case .emphasis = content.first {
            #expect(true)
        } else {
            Issue.record("Failed to parse italic text")
        }
        
        // Code
        let code = MarkdownParser.parse("`code`")
        if case let .paragraph(content) = code.blocks.first,
           case .code = content.first {
            #expect(true)
        } else {
            Issue.record("Failed to parse inline code")
        }
        
        // Link
        let link = MarkdownParser.parse("[text](url)")
        if case let .paragraph(content) = link.blocks.first,
           case .link = content.first {
            #expect(true)
        } else {
            Issue.record("Failed to parse link")
        }
        
        // Image
        let image = MarkdownParser.parse("![alt](image.png)")
        if case let .paragraph(content) = image.blocks.first,
           case .image = content.first {
            #expect(true)
        } else {
            Issue.record("Failed to parse image")
        }
    }
    
    @Test("Complex document parsing")
    func testComplexDocument() {
        let markdown = """
        # Main Heading
        
        This is a paragraph with **bold** and *italic* text.
        
        ## Subheading
        
        - List item 1
        - List item 2
          - Nested item
        
        ```swift
        let code = "example"
        ```
        
        > This is a blockquote
        > with multiple lines
        
        ---
        
        [Link](https://example.com) and ![Image](image.png)
        """
        
        let document = MarkdownParser.parse(markdown)
        #expect(document.blocks.count > 5, "Complex document should have multiple blocks")
        
        // Verify different block types exist
        var hasHeading = false
        var hasParagraph = false
        var hasList = false
        var hasCodeBlock = false
        var hasBlockquote = false
        var hasHorizontalRule = false
        
        for block in document.blocks {
            switch block {
            case .heading: hasHeading = true
            case .paragraph: hasParagraph = true
            case .list: hasList = true
            case .codeBlock: hasCodeBlock = true
            case .blockquote: hasBlockquote = true
            case .horizontalRule: hasHorizontalRule = true
            default: break
            }
        }
        
        #expect(hasHeading, "Should have heading")
        #expect(hasParagraph, "Should have paragraph")
        #expect(hasList, "Should have list")
        #expect(hasCodeBlock, "Should have code block")
        #expect(hasBlockquote, "Should have blockquote")
        #expect(hasHorizontalRule, "Should have horizontal rule")
    }
}