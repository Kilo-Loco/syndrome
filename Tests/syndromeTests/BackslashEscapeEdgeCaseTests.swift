import Testing
@testable import syndrome

@Suite("Backslash Escape Edge Cases - MVP-001")
struct BackslashEscapeEdgeCaseTests {
    
    @Test("Backslash at end of line")
    func backslashAtEndOfLine() {
        let markdown = "text\\"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .text(let text) = content.first else {
            Issue.record("Expected text")
            return
        }
        
        #expect(text == "text\\", "Backslash at end should be literal")
    }
    
    @Test("Multiple consecutive backslashes")
    func multipleConsecutiveBackslashes() {
        // Test cases from the ticket
        let testCases = [
            (markdown: "\\\\\\\\", expected: "\\\\"),  // 4 backslashes -> 2
            (markdown: "\\\\", expected: "\\"),        // 2 backslashes -> 1
            (markdown: "\\\\\\\\\\\\", expected: "\\\\\\")  // 6 backslashes -> 3
        ]
        
        for test in testCases {
            let doc = MarkdownParser.parse(test.markdown)
            
            guard case .paragraph(let content) = doc.blocks.first else {
                Issue.record("Expected paragraph for: \(test.markdown)")
                continue
            }
            
            var fullText = ""
            for element in content {
                if case .text(let t) = element {
                    fullText += t
                }
            }
            
            #expect(fullText == test.expected, 
                   "Input '\(test.markdown)' should produce '\(test.expected)', got '\(fullText)'")
        }
    }
    
    @Test("Escaped backslash with text")
    func escapedBackslashWithText() {
        let markdown = "\\\\double backslash"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var fullText = ""
        for element in content {
            if case .text(let t) = element {
                fullText += t
            }
        }
        
        #expect(fullText == "\\double backslash", "Should show single backslash")
    }
    
    @Test("Invalid escape sequences")
    func invalidEscapeSequences() {
        let testCases = [
            (markdown: "\\a", expected: "\\a"),
            (markdown: "\\b", expected: "\\b"),
            (markdown: "\\anon-special", expected: "\\anon-special"),
            (markdown: "\\1", expected: "\\1"),
            (markdown: "\\ space", expected: "\\ space")
        ]
        
        for test in testCases {
            let doc = MarkdownParser.parse(test.markdown)
            
            guard case .paragraph(let content) = doc.blocks.first,
                  case .text(let text) = content.first else {
                Issue.record("Expected text for: \(test.markdown)")
                continue
            }
            
            #expect(text == test.expected, 
                   "Non-special char '\(test.markdown)' should remain as-is")
        }
    }
    
    @Test("Escapes within formatted text")
    func escapesWithinFormattedText() {
        // Escapes should work inside emphasis
        let markdown1 = "*text with \\* asterisk*"
        let doc1 = MarkdownParser.parse(markdown1)
        
        guard case .paragraph(let content1) = doc1.blocks.first,
              case .emphasis(let emphContent) = content1.first else {
            Issue.record("Expected emphasis")
            return
        }
        
        var emphText = ""
        for element in emphContent {
            if case .text(let t) = element {
                emphText += t
            }
        }
        #expect(emphText == "text with * asterisk")
        
        // Escapes should work inside strong
        let markdown2 = "**text with \\* asterisk**"
        let doc2 = MarkdownParser.parse(markdown2)
        
        guard case .paragraph(let content2) = doc2.blocks.first,
              case .strongEmphasis(let strongContent) = content2.first else {
            Issue.record("Expected strongEmphasis")
            return
        }
        
        var strongText = ""
        for element in strongContent {
            if case .text(let t) = element {
                strongText += t
            }
        }
        #expect(strongText == "text with * asterisk")
    }
    
    @Test("Escapes in block elements")
    func escapesInBlockElements() {
        // In heading
        let heading = "# Title with \\* literal asterisk"
        let doc1 = MarkdownParser.parse(heading)
        
        guard case .heading(let level, let headingContent) = doc1.blocks.first else {
            Issue.record("Expected heading")
            return
        }
        
        #expect(level == 1)
        var headingText = ""
        for element in headingContent {
            if case .text(let t) = element {
                headingText += t
            }
        }
        #expect(headingText.contains("* literal asterisk"))
        
        // In list item
        let list = "- Item with \\* asterisk"
        let doc2 = MarkdownParser.parse(list)
        
        guard case .list(let items, _) = doc2.blocks.first,
              let firstItem = items.first,
              case .paragraph(let listContent) = firstItem.content.first else {
            Issue.record("Expected list with paragraph")
            return
        }
        
        var listText = ""
        for element in listContent {
            if case .text(let t) = element {
                listText += t
            }
        }
        #expect(listText.contains("* asterisk"))
        
        // In blockquote
        let quote = "> Quote with \\* asterisk"
        let doc3 = MarkdownParser.parse(quote)
        
        guard case .blockquote(let quoteBlocks) = doc3.blocks.first,
              case .paragraph(let quoteContent) = quoteBlocks.first else {
            Issue.record("Expected blockquote with paragraph")
            return
        }
        
        var quoteText = ""
        for element in quoteContent {
            if case .text(let t) = element {
                quoteText += t
            }
        }
        #expect(quoteText.contains("* asterisk"))
    }
    
    @Test("Complex escape scenarios from ticket")
    func complexEscapeScenarios() {
        // Test the exact examples from the ticket
        let testCases = [
            (markdown: "This \\*should\\* not be italic", 
             expected: "This *should* not be italic"),
            (markdown: "Use \\` for inline code", 
             expected: "Use ` for inline code")
        ]
        
        for test in testCases {
            let doc = MarkdownParser.parse(test.markdown)
            
            guard case .paragraph(let content) = doc.blocks.first else {
                Issue.record("Expected paragraph for: \(test.markdown)")
                continue
            }
            
            var fullText = ""
            for element in content {
                if case .text(let t) = element {
                    fullText += t
                }
            }
            
            #expect(fullText == test.expected,
                   "'\(test.markdown)' should produce '\(test.expected)', got '\(fullText)'")
        }
    }
    
    @Test("Trailing backslash edge case")
    func trailingBackslash() {
        let markdown = "trailing backslash\\"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph(let content) = doc.blocks.first,
              case .text(let text) = content.first else {
            Issue.record("Expected text")
            return
        }
        
        #expect(text == "trailing backslash\\", "Trailing backslash should be preserved")
    }
}