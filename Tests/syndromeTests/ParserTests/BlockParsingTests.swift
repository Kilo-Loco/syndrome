import Testing
@testable import syndrome

@Suite("Block Parsing")
struct BlockParsingTests {
    
    // MARK: - ATX Headings
    
    @Test("Parse ATX headings", arguments: [
        (markdown: "# H1", level: 1, text: "H1"),
        (markdown: "## H2", level: 2, text: "H2"),
        (markdown: "### H3", level: 3, text: "H3"),
        (markdown: "#### H4", level: 4, text: "H4"),
        (markdown: "##### H5", level: 5, text: "H5"),
        (markdown: "###### H6", level: 6, text: "H6")
    ])
    func parseATXHeading(data: (markdown: String, level: Int, text: String)) {
        let doc = MarkdownParser.parse(data.markdown)
        
        #expect(doc.blocks.count == 1)
        guard case .heading(let level, let content) = doc.blocks.first else {
            Issue.record("Expected heading")
            return
        }
        
        #expect(level == data.level)
        if case .text(let text) = content.first {
            #expect(text == data.text)
        }
    }
    
    @Test("Reject invalid headings")
    func rejectInvalidHeadings() {
        let invalidCases = [
            "####### Seven hashes",
            "######## Eight hashes"
        ]
        
        for markdown in invalidCases {
            let doc = MarkdownParser.parse(markdown)
            guard case .paragraph = doc.blocks.first else {
                Issue.record("Invalid heading should become paragraph")
                return
            }
        }
    }
    
    // MARK: - Paragraphs
    
    @Test("Parse simple paragraphs")
    func parseSimpleParagraphs() {
        let markdown = "This is a paragraph."
        let doc = MarkdownParser.parse(markdown)
        
        #expect(doc.blocks.count == 1)
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        if case .text(let text) = content.first {
            #expect(text == "This is a paragraph.")
        }
    }
    
    @Test("Parse multi-line paragraphs")
    func parseMultiLineParagraphs() {
        let markdown = """
        This is line one
        This is line two
        """
        
        let doc = MarkdownParser.parse(markdown)
        #expect(doc.blocks.count == 1)
        guard case .paragraph = doc.blocks.first else {
            Issue.record("Expected single paragraph for continuous lines")
            return
        }
    }
    
    // MARK: - Code Blocks
    
    @Test("Parse fenced code blocks", arguments: [
        (fence: "```", lang: nil, code: "code"),
        (fence: "```swift", lang: "swift", code: "let x = 1"),
        (fence: "~~~", lang: nil, code: "code"),
        (fence: "~~~python", lang: "python", code: "print('hello')")
    ])
    func parseFencedCodeBlock(data: (fence: String, lang: String?, code: String)) {
        let markdown = """
        \(data.fence)
        \(data.code)
        \(data.fence.prefix(3))
        """
        
        let doc = MarkdownParser.parse(markdown)
        
        guard case .codeBlock(let info, let content) = doc.blocks.first else {
            Issue.record("Expected code block")
            return
        }
        
        #expect(info == data.lang)
        #expect(content.trimmingCharacters(in: .whitespacesAndNewlines) == data.code)
    }
    
    // MARK: - Lists
    
    @Test("Parse unordered lists", arguments: ["-", "*", "+"])
    func parseUnorderedList(marker: String) {
        let markdown = """
        \(marker) Item 1
        \(marker) Item 2
        """
        
        let doc = MarkdownParser.parse(markdown)
        
        guard case .list(let items, let type) = doc.blocks.first else {
            Issue.record("Expected list")
            return
        }
        
        #expect(items.count == 2)
        if case .unordered(let m) = type {
            #expect(String(m) == marker)
        } else {
            Issue.record("Expected unordered list")
        }
    }
    
    @Test("Parse ordered lists")
    func parseOrderedList() {
        let markdown = """
        1. First
        2. Second
        3. Third
        """
        
        let doc = MarkdownParser.parse(markdown)
        
        guard case .list(let items, let type) = doc.blocks.first else {
            Issue.record("Expected list")
            return
        }
        
        #expect(items.count == 3)
        guard case .ordered(let start, let delim) = type else {
            Issue.record("Expected ordered list")
            return
        }
        
        #expect(start == 1)
        #expect(delim == ".")
    }
    
    // MARK: - Blockquotes
    
    @Test("Parse blockquotes")
    func parseBlockquotes() {
        let markdown = "> This is a quote"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .blockquote(let content) = doc.blocks.first else {
            Issue.record("Expected blockquote")
            return
        }
        
        #expect(content.count == 1)
        guard case .paragraph = content.first else {
            Issue.record("Expected paragraph in blockquote")
            return
        }
    }
    
    @Test("Parse nested blockquotes")
    func parseNestedBlockquotes() {
        let markdown = """
        > Level 1
        >> Level 2
        """
        
        let doc = MarkdownParser.parse(markdown)
        
        guard case .blockquote(let content) = doc.blocks.first else {
            Issue.record("Expected blockquote")
            return
        }
        
        #expect(content.count > 0)
    }
    
    // MARK: - Horizontal Rules
    
    @Test("Parse horizontal rules", arguments: [
        "---",
        "***",
        "___",
        "- - -",
        "* * *",
        "_ _ _"
    ])
    func parseHorizontalRule(markdown: String) {
        let doc = MarkdownParser.parse(markdown)
        
        guard case .horizontalRule = doc.blocks.first else {
            Issue.record("Expected horizontal rule for: \(markdown)")
            return
        }
    }
}