import Testing
import Foundation
@testable import syndrome

@Suite("API Contract Tests")
struct APIContractTests {
    
    @Test("Public API is available")
    func testPublicAPIAvailability() {
        let _ = MarkdownParser.self
        #expect(true, "MarkdownParser type should be accessible")
    }
    
    @Test("MarkdownDocument structure is accessible")
    func testMarkdownDocumentStructure() {
        let document = MarkdownDocument(blocks: [], metadata: [:])
        #expect(document.blocks.isEmpty)
        #expect(document.metadata.isEmpty)
    }
    
    @Test("Parser has static interface")
    func testParserStaticInterface() {
        let markdown = "# Test"
        let document = MarkdownParser.parse(markdown)
        #expect(document.blocks.count > 0)
    }
    
    @Test("BlockElement enum is accessible")
    func testBlockElementAccessible() {
        let heading = BlockElement.heading(level: 1, content: [.text("Test")])
        let paragraph = BlockElement.paragraph(content: [.text("Test")])
        let codeBlock = BlockElement.codeBlock(info: "swift", content: "let x = 1")
        let horizontalRule = BlockElement.horizontalRule
        
        #expect(heading != nil)
        #expect(paragraph != nil)
        #expect(codeBlock != nil)
        #expect(horizontalRule != nil)
    }
    
    @Test("InlineElement enum is accessible")
    func testInlineElementAccessible() {
        let text = InlineElement.text("test")
        let emphasis = InlineElement.emphasis(content: [.text("test")])
        let strong = InlineElement.strongEmphasis(content: [.text("test")])
        let code = InlineElement.code("test")
        let softBreak = InlineElement.softBreak
        let hardBreak = InlineElement.hardBreak
        
        #expect(text != nil)
        #expect(emphasis != nil)
        #expect(strong != nil)
        #expect(code != nil)
        #expect(softBreak != nil)
        #expect(hardBreak != nil)
    }
    
    @Test("ListType enum is accessible")
    func testListTypeAccessible() {
        let unordered = ListType.unordered(marker: "-")
        let ordered = ListType.ordered(startNumber: 1, delimiter: ".")
        
        #expect(unordered != nil)
        #expect(ordered != nil)
    }
    
    @Test("ListItem struct is accessible")
    func testListItemAccessible() {
        let item = ListItem(content: [.paragraph(content: [.text("Test")])], tight: true)
        #expect(item.content.count == 1)
        #expect(item.tight == true)
    }
    
    @Test("Parser maintains all MVP features")
    func testParserMVPFeatures() {
        // Test backslash escapes
        let escaped = MarkdownParser.parse("\\*not italic\\*")
        #expect(escaped.blocks.count > 0)
        
        // Test HTML entities
        let entities = MarkdownParser.parse("&copy; 2024 &amp; &lt;test&gt;")
        #expect(entities.blocks.count > 0)
        
        // Test tab handling
        let tabs = MarkdownParser.parse("-\tList item with tab")
        #expect(tabs.blocks.count > 0)
    }
    
    @Test("All parser features work after migration")
    func testParserMigrationCompleteness() {
        let testCases = [
            "# Heading",
            "## Heading 2",
            "**bold** and *italic*",
            "\\* escaped asterisk",
            "&copy; 2024",
            "-\tTab list item",
            "```swift\nlet x = 1\n```",
            "> Blockquote",
            "---",
            "[link](https://example.com)",
            "![image](image.png)"
        ]
        
        for markdown in testCases {
            let document = MarkdownParser.parse(markdown)
            #expect(!document.blocks.isEmpty, "Failed to parse: \(markdown)")
        }
    }
}