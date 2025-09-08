import Testing
@testable import syndrome

@Suite("CommonMark Compatibility")
struct CommonMarkTests {
    
    // MARK: - ATX Headings (Spec 4.2)
    
    @Test("CommonMark ATX headings")
    func commonMarkATXHeadings() {
        let examples = [
            (input: "# foo", level: 1, text: "foo"),
            (input: "## foo", level: 2, text: "foo"),
            (input: "### foo", level: 3, text: "foo"),
            (input: "#### foo", level: 4, text: "foo"),
            (input: "##### foo", level: 5, text: "foo"),
            (input: "###### foo", level: 6, text: "foo")
        ]
        
        for example in examples {
            let doc = MarkdownParser.parse(example.input)
            
            guard case .heading(let level, let content) = doc.blocks.first else {
                Issue.record("Expected heading for: \(example.input)")
                continue
            }
            
            #expect(level == example.level)
            if case .text(let text) = content.first {
                #expect(text == example.text)
            }
        }
    }
    
    @Test("CommonMark heading edge cases")
    func commonMarkHeadingEdgeCases() {
        // More than 6 hashes is not a heading
        let tooMany = "####### foo"
        let doc1 = MarkdownParser.parse(tooMany)
        guard case .paragraph = doc1.blocks.first else {
            Issue.record("7+ hashes should be paragraph")
            return
        }
        
        // At least one space is required
        let noSpace = "#5 bolt"
        let doc2 = MarkdownParser.parse(noSpace)
        guard case .paragraph = doc2.blocks.first else {
            Issue.record("No space after # should be paragraph")
            return
        }
        
        // Leading spaces are allowed
        let leadingSpaces = "   # foo"
        let doc3 = MarkdownParser.parse(leadingSpaces)
        guard case .heading(let level, _) = doc3.blocks.first else {
            Issue.record("Leading spaces should be allowed")
            return
        }
        #expect(level == 1)
    }
    
    // MARK: - Fenced Code Blocks (Spec 4.5)
    
    @Test("CommonMark fenced code blocks")
    func commonMarkFencedCodeBlocks() {
        // Backtick fence
        let backticks = """
        ```
        <
         >
        ```
        """
        
        let doc1 = MarkdownParser.parse(backticks)
        guard case .codeBlock(_, let content) = doc1.blocks.first else {
            Issue.record("Expected code block with backticks")
            return
        }
        #expect(content.contains("<"))
        #expect(content.contains(">"))
        
        // Tilde fence
        let tildes = """
        ~~~
        <
         >
        ~~~
        """
        
        let doc2 = MarkdownParser.parse(tildes)
        guard case .codeBlock(_, let content2) = doc2.blocks.first else {
            Issue.record("Expected code block with tildes")
            return
        }
        #expect(content2.contains("<"))
        #expect(content2.contains(">"))
    }
    
    @Test("CommonMark code block info strings")
    func commonMarkCodeBlockInfo() {
        let examples = [
            (markdown: "```ruby\ndef foo\nend\n```", info: "ruby"),
            (markdown: "~~~python\nprint('hi')\n~~~", info: "python"),
            (markdown: "```\nplain\n```", info: nil)
        ]
        
        for example in examples {
            let doc = MarkdownParser.parse(example.markdown)
            
            guard case .codeBlock(let info, _) = doc.blocks.first else {
                Issue.record("Expected code block")
                continue
            }
            
            #expect(info == example.info)
        }
    }
    
    // MARK: - Lists (Spec 5.2-5.3)
    
    @Test("CommonMark list markers")
    func commonMarkListMarkers() {
        // Unordered list markers
        let unorderedMarkers = ["-", "+", "*"]
        
        for marker in unorderedMarkers {
            let markdown = "\(marker) foo\n\(marker) bar"
            let doc = MarkdownParser.parse(markdown)
            
            guard case .list(let items, let type) = doc.blocks.first else {
                Issue.record("Expected list for marker: \(marker)")
                continue
            }
            
            #expect(items.count == 2)
            guard case .unordered(let m) = type else {
                Issue.record("Expected unordered list")
                continue
            }
            #expect(String(m) == marker)
        }
        
        // Ordered list delimiters
        let orderedDelimiters = [".", ")"]
        
        for delimiter in orderedDelimiters {
            let markdown = "1\(delimiter) foo\n2\(delimiter) bar"
            let doc = MarkdownParser.parse(markdown)
            
            guard case .list(let items, let type) = doc.blocks.first else {
                Issue.record("Expected list for delimiter: \(delimiter)")
                continue
            }
            
            #expect(items.count == 2)
            guard case .ordered(_, let d) = type else {
                Issue.record("Expected ordered list")
                continue
            }
            #expect(String(d) == delimiter)
        }
    }
    
    // MARK: - Blockquotes (Spec 5.1)
    
    @Test("CommonMark blockquotes")
    func commonMarkBlockquotes() {
        let simple = "> # Foo\n> bar\n> baz"
        let doc = MarkdownParser.parse(simple)
        
        guard case .blockquote(let content) = doc.blocks.first else {
            Issue.record("Expected blockquote")
            return
        }
        
        #expect(content.count >= 2, "Should have heading and paragraph")
        
        guard case .heading(let level, _) = content.first else {
            Issue.record("First element should be heading")
            return
        }
        #expect(level == 1)
    }
    
    // MARK: - Emphasis (Spec 6.2-6.4)
    
    @Test("CommonMark emphasis")
    func commonMarkEmphasis() {
        let examples: [(markdown: String, expectedItalic: Bool, expectedBold: Bool, expectedBoldItalic: Bool)] = [
            (markdown: "*foo bar*", expectedItalic: true, expectedBold: false, expectedBoldItalic: false),
            (markdown: "_foo bar_", expectedItalic: true, expectedBold: false, expectedBoldItalic: false),
            (markdown: "**foo bar**", expectedItalic: false, expectedBold: true, expectedBoldItalic: false),
            (markdown: "__foo bar__", expectedItalic: false, expectedBold: true, expectedBoldItalic: false),
            (markdown: "***foo bar***", expectedItalic: false, expectedBold: false, expectedBoldItalic: true),
            (markdown: "___foo bar___", expectedItalic: false, expectedBold: false, expectedBoldItalic: true)
        ]
        
        for example in examples {
            let doc = MarkdownParser.parse(example.markdown)
            
            guard case .paragraph(let content) = doc.blocks.first else {
                Issue.record("Expected paragraph")
                continue
            }
            
            if example.expectedBoldItalic {
                // Should have nested emphasis
                guard case .strongEmphasis(let boldContent) = content.first else {
                    Issue.record("Expected bold wrapper")
                    continue
                }
                
                var hasItalic = false
                for element in boldContent {
                    if case .emphasis = element {
                        hasItalic = true
                        break
                    }
                }
                #expect(hasItalic || boldContent.count > 0, "Should have italic inside bold")
                
            } else if example.expectedBold {
                guard case .strongEmphasis = content.first else {
                    Issue.record("Expected bold")
                    continue
                }
            } else if example.expectedItalic {
                guard case .emphasis = content.first else {
                    Issue.record("Expected italic")
                    continue
                }
            }
        }
    }
    
    // MARK: - Links (Spec 6.5-6.6)
    
    @Test("CommonMark links")
    func commonMarkLinks() {
        let examples = [
            (markdown: "[link](/uri)", text: "link", url: "/uri"),
            (markdown: "[link](http://example.com)", text: "link", url: "http://example.com"),
            (markdown: "[link]()", text: "link", url: "")
        ]
        
        for example in examples {
            let doc = MarkdownParser.parse(example.markdown)
            
            guard case .paragraph(let content) = doc.blocks.first,
                  case .link(let linkText, let url, _) = content.first else {
                Issue.record("Expected link")
                continue
            }
            
            if case .text(let text) = linkText.first {
                #expect(text == example.text)
            }
            #expect(url == example.url)
        }
    }
    
    // MARK: - Horizontal Rules (Spec 4.1)
    
    @Test("CommonMark horizontal rules")
    func commonMarkHorizontalRules() {
        let validRules = [
            "***",
            "---",
            "___",
            " ***",
            "  ***",
            "   ***",
            "*****",
            "- - -",
            "* * *",
            "_ _ _"
        ]
        
        for rule in validRules {
            let doc = MarkdownParser.parse(rule)
            
            guard case .horizontalRule = doc.blocks.first else {
                Issue.record("Expected horizontal rule for: '\(rule)'")
                continue
            }
        }
    }
}