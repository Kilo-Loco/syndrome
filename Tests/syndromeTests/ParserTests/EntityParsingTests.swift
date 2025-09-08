import Testing
@testable import syndrome

@Suite("Entity and Escape Parsing")
struct EntityParsingTests {
    
    // MARK: - HTML Entities
    
    @Test("Parse core HTML entities", arguments: [
        (entity: "&amp;", expected: "&"),
        (entity: "&lt;", expected: "<"),
        (entity: "&gt;", expected: ">"),
        (entity: "&quot;", expected: "\""),
        (entity: "&apos;", expected: "'")
    ])
    func parseCoreEntity(data: (entity: String, expected: String)) {
        let doc = MarkdownParser.parse(data.entity)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .text(let text) = content.first else {
            Issue.record("Expected text with entity")
            return
        }
        
        #expect(text == data.expected)
    }
    
    @Test("Parse named entities", arguments: [
        (entity: "&copy;", expected: "©"),
        (entity: "&reg;", expected: "®"),
        (entity: "&trade;", expected: "™"),
        (entity: "&mdash;", expected: "—"),
        (entity: "&ndash;", expected: "–"),
        (entity: "&hellip;", expected: "…"),
        (entity: "&nbsp;", expected: "\u{00A0}")
    ])
    func parseNamedEntity(data: (entity: String, expected: String)) {
        let doc = MarkdownParser.parse(data.entity)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .text(let text) = content.first else {
            Issue.record("Expected text with entity")
            return
        }
        
        #expect(text == data.expected)
    }
    
    @Test("Parse numeric entities")
    func parseNumericEntities() {
        let testCases = [
            (entity: "&#169;", expected: "©"),      // Decimal
            (entity: "&#x00A9;", expected: "©"),    // Hexadecimal lowercase
            (entity: "&#X00A9;", expected: "©"),    // Hexadecimal uppercase
            (entity: "&#8594;", expected: "→"),     // Arrow
            (entity: "&#x2192;", expected: "→")     // Arrow hex
        ]
        
        for test in testCases {
            let doc = MarkdownParser.parse(test.entity)
            
            guard case .paragraph(let content) = doc.blocks.first,
                  case .text(let text) = content.first else {
                Issue.record("Expected text for entity: \(test.entity)")
                continue
            }
            
            #expect(text == test.expected, "Entity \(test.entity) should produce \(test.expected)")
        }
    }
    
    @Test("Entities not processed in code")
    func entitiesNotInCode() {
        // Inline code
        let inlineCode = "`&amp; &lt; &gt;`"
        let doc1 = MarkdownParser.parse(inlineCode)
        
        guard case .paragraph(let content) = doc1.blocks.first,
              case .code(let code) = content.first else {
            Issue.record("Expected inline code")
            return
        }
        
        #expect(code.contains("&amp;"), "Entities should not be processed in inline code")
        
        // Code block
        let codeBlock = """
        ```
        &amp; &lt; &gt;
        ```
        """
        let doc2 = MarkdownParser.parse(codeBlock)
        
        guard case .codeBlock(_, let blockContent) = doc2.blocks.first else {
            Issue.record("Expected code block")
            return
        }
        
        #expect(blockContent.contains("&amp;"), "Entities should not be processed in code blocks")
    }
    
    // MARK: - Backslash Escapes
    
    @Test("Parse backslash escapes", arguments: [
        (markdown: "\\*not italic\\*", expected: "*not italic*"),
        (markdown: "\\_not italic\\_", expected: "_not italic_"),
        (markdown: "\\`not code\\`", expected: "`not code`"),
        (markdown: "\\[not link\\]", expected: "[not link]"),
        (markdown: "\\!not image", expected: "!not image"),
        (markdown: "\\#not heading", expected: "#not heading"),
        (markdown: "\\+not list", expected: "+not list"),
        (markdown: "\\-not list", expected: "-not list"),
        (markdown: "\\(parenthesis\\)", expected: "(parenthesis)")
    ])
    func parseEscape(data: (markdown: String, expected: String)) {
        let doc = MarkdownParser.parse(data.markdown)
        
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var fullText = ""
        for element in content {
            if case .text(let text) = element {
                fullText += text
            }
        }
        
        #expect(fullText == data.expected)
    }
    
    @Test("Non-special character escapes")
    func nonSpecialEscapes() {
        let markdown = "\\a \\b \\c"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .text(let text) = content.first else {
            Issue.record("Expected text")
            return
        }
        
        #expect(text == "\\a \\b \\c", "Non-special chars should not be escaped")
    }
    
    @Test("Escape in different contexts")
    func escapeInContexts() {
        // In heading
        let heading = "# Heading with \\*asterisks\\*"
        let doc1 = MarkdownParser.parse(heading)
        
        guard case .heading(_, let headingContent) = doc1.blocks.first else {
            Issue.record("Expected heading")
            return
        }
        
        var headingText = ""
        for element in headingContent {
            if case .text(let text) = element {
                headingText += text
            }
        }
        #expect(headingText.contains("*"), "Escaped asterisks should appear in heading")
        
        // In list
        let list = "- Item with \\*asterisks\\*"
        let doc2 = MarkdownParser.parse(list)
        
        guard case .list(let items, _) = doc2.blocks.first else {
            Issue.record("Expected list")
            return
        }
        
        #expect(items.count == 1)
        
        // In blockquote
        let quote = "> Quote with \\*asterisks\\*"
        let doc3 = MarkdownParser.parse(quote)
        
        guard case .blockquote = doc3.blocks.first else {
            Issue.record("Expected blockquote")
            return
        }
    }
    
    @Test("Multiple consecutive escapes")
    func multipleEscapes() {
        let markdown = "\\*\\*not bold\\*\\*"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var text = ""
        for element in content {
            if case .text(let t) = element {
                text += t
            }
        }
        
        #expect(text == "**not bold**")
    }
}