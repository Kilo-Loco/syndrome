import Testing
@testable import syndrome

@Suite("Inline Parsing")
struct InlineParsingTests {
    
    // MARK: - Emphasis
    
    @Test("Parse italic text", arguments: [
        (markdown: "*italic*", expected: "italic"),
        (markdown: "_italic_", expected: "italic"),
        (markdown: "*multiple words*", expected: "multiple words"),
        (markdown: "_multiple words_", expected: "multiple words")
    ])
    func parseItalic(data: (markdown: String, expected: String)) {
        let doc = MarkdownParser.parse(data.markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .emphasis(let emphContent) = content.first,
              case .text(let text) = emphContent.first else {
            Issue.record("Expected italic text")
            return
        }
        
        #expect(text == data.expected)
    }
    
    @Test("Parse bold text", arguments: [
        (markdown: "**bold**", expected: "bold"),
        (markdown: "__bold__", expected: "bold"),
        (markdown: "**multiple words**", expected: "multiple words"),
        (markdown: "__multiple words__", expected: "multiple words")
    ])
    func parseBold(data: (markdown: String, expected: String)) {
        let doc = MarkdownParser.parse(data.markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .strongEmphasis(let boldContent) = content.first,
              case .text(let text) = boldContent.first else {
            Issue.record("Expected bold text")
            return
        }
        
        #expect(text == data.expected)
    }
    
    @Test("Parse nested emphasis")
    func parseNestedEmphasis() {
        let markdown = "**bold with *italic* inside**"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .strongEmphasis(let boldContent) = content.first else {
            Issue.record("Expected bold wrapper")
            return
        }
        
        #expect(boldContent.count == 3) // "bold with ", italic, " inside"
    }
    
    // MARK: - Code
    
    @Test("Parse inline code", arguments: [
        "`code`",
        "`let x = 1`",
        "``code with ` backtick``",
        "` spaces `"
    ])
    func parseInlineCode(markdown: String) {
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .code = content.first else {
            Issue.record("Expected inline code")
            return
        }
    }
    
    // MARK: - Links
    
    @Test("Parse links", arguments: [
        (markdown: "[text](url)", text: "text", url: "url", title: nil),
        (markdown: "[link](https://example.com)", text: "link", url: "https://example.com", title: nil),
        (markdown: "[title](url \"tooltip\")", text: "title", url: "url", title: "tooltip"),
        (markdown: "[empty]()", text: "empty", url: "", title: nil)
    ])
    func parseLink(data: (markdown: String, text: String, url: String, title: String?)) {
        let doc = MarkdownParser.parse(data.markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .link(let linkText, let url, let title) = content.first else {
            Issue.record("Expected link")
            return
        }
        
        if case .text(let text) = linkText.first {
            #expect(text == data.text)
        }
        #expect(url == data.url)
        #expect(title == data.title)
    }
    
    // MARK: - Images
    
    @Test("Parse images", arguments: [
        (markdown: "![alt](url)", alt: "alt", url: "url", title: nil),
        (markdown: "![](image.png)", alt: "", url: "image.png", title: nil),
        (markdown: "![desc](img.jpg \"title\")", alt: "desc", url: "img.jpg", title: "title")
    ])
    func parseImage(data: (markdown: String, alt: String, url: String, title: String?)) {
        let doc = MarkdownParser.parse(data.markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .image(let altContent, let url, let title) = content.first else {
            Issue.record("Expected image")
            return
        }
        
        if altContent.isEmpty {
            #expect(data.alt.isEmpty)
        } else if case .text(let text) = altContent.first {
            #expect(text == data.alt)
        }
        #expect(url == data.url)
        #expect(title == data.title)
    }
    
    // MARK: - Line Breaks
    
    @Test("Parse hard breaks")
    func parseHardBreaks() {
        let markdown = "Line one  \nLine two"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var hasHardBreak = false
        for element in content {
            if case .hardBreak = element {
                hasHardBreak = true
                break
            }
        }
        
        #expect(hasHardBreak, "Should contain hard break")
    }
    
    @Test("Parse soft breaks")
    func parseSoftBreaks() {
        let markdown = "Line one\nLine two"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var hasSoftBreak = false
        for element in content {
            if case .softBreak = element {
                hasSoftBreak = true
                break
            }
        }
        
        #expect(hasSoftBreak, "Should contain soft break")
    }
    
    // MARK: - Mixed Content
    
    @Test("Parse mixed inline elements")
    func parseMixedInline() {
        let markdown = "Text with **bold**, *italic*, `code`, [link](url), and ![img](pic.png)."
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var hasBold = false
        var hasItalic = false
        var hasCode = false
        var hasLink = false
        var hasImage = false
        
        for element in content {
            switch element {
            case .strongEmphasis: hasBold = true
            case .emphasis: hasItalic = true
            case .code: hasCode = true
            case .link: hasLink = true
            case .image: hasImage = true
            default: break
            }
        }
        
        #expect(hasBold, "Should have bold")
        #expect(hasItalic, "Should have italic")
        #expect(hasCode, "Should have code")
        #expect(hasLink, "Should have link")
        #expect(hasImage, "Should have image")
    }
}