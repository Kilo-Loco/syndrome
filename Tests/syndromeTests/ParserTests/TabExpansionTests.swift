import Testing
@testable import syndrome

@Suite("Tab Expansion")
struct TabExpansionTests {
    
    @Test("Tab expansion in lists")
    func tabsInLists() {
        let markdown = "-\tList item with tab"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .list(let items, _) = doc.blocks.first else {
            Issue.record("Expected list")
            return
        }
        
        #expect(items.count == 1, "Should parse list with tab after marker")
    }
    
    @Test("Tab expansion in headings")
    func tabsInHeadings() {
        let markdown = "#\tHeading with tab"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .heading(let level, let content) = doc.blocks.first else {
            Issue.record("Expected heading")
            return
        }
        
        #expect(level == 1)
        if case .text(let text) = content.first {
            #expect(text == "Heading with tab")
        }
    }
    
    @Test("Tab expansion preserves alignment")
    func tabAlignment() {
        let testCases = [
            (input: "a\tb", column: 1, expected: 3),   // 'a' at 0, tab expands to position 4
            (input: "ab\tc", column: 2, expected: 2),  // 'ab' at 0-1, tab expands to position 4
            (input: "abc\td", column: 3, expected: 1), // 'abc' at 0-2, tab expands to position 4
            (input: "abcd\te", column: 4, expected: 4) // 'abcd' at 0-3, tab expands to position 8
        ]
        
        for test in testCases {
            let doc = MarkdownParser.parse(test.input)
            
            guard case .paragraph(let content) = doc.blocks.first,
                  case .text(let text) = content.first else {
                Issue.record("Expected text")
                continue
            }
            
            // Count spaces where tab was
            let parts = test.input.split(separator: "\t")
            let beforeTab = String(parts[0])
            let spacesAdded = text.count - beforeTab.count - (parts.count > 1 ? parts[1].count : 0)
            
            #expect(spacesAdded == test.expected, 
                   "Tab at column \(test.column) should expand to \(test.expected) spaces")
        }
    }
    
    @Test("Tab in code blocks")
    func tabsInCodeBlocks() {
        let markdown = """
        ```
        \tindented code
        \t\tdoubly indented
        ```
        """
        
        let doc = MarkdownParser.parse(markdown)
        
        guard case .codeBlock(_, let content) = doc.blocks.first else {
            Issue.record("Expected code block")
            return
        }
        
        #expect(content.contains("    indented"), "Single tab should expand to 4 spaces")
        #expect(content.contains("        doubly"), "Double tab should expand to 8 spaces")
    }
    
    @Test("Mixed tabs and spaces")
    func mixedTabsSpaces() {
        let markdown = "  \t  Text with mixed indentation"
        let doc = MarkdownParser.parse(markdown)
        
        guard case .paragraph = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        // Should handle mixed tabs and spaces correctly
    }
    
    @Test("Tab after list markers")
    func tabAfterListMarkers() {
        let unorderedTests = [
            "-\tItem",
            "*\tItem",
            "+\tItem"
        ]
        
        for markdown in unorderedTests {
            let doc = MarkdownParser.parse(markdown)
            
            guard case .list(let items, _) = doc.blocks.first else {
                Issue.record("Expected list for: \(markdown)")
                continue
            }
            
            #expect(items.count == 1)
        }
        
        let orderedTests = [
            "1.\tFirst",
            "2)\tSecond"
        ]
        
        for markdown in orderedTests {
            let doc = MarkdownParser.parse(markdown)
            
            guard case .list(let items, _) = doc.blocks.first else {
                Issue.record("Expected list for: \(markdown)")
                continue
            }
            
            #expect(items.count == 1)
        }
    }
    
    @Test("Tab expansion consistency")
    func tabConsistency() {
        // Test that tab expansion is consistent across the document
        let markdown = """
        \tFirst line with tab
        \tSecond line with tab
        \tThird line with tab
        """
        
        let doc = MarkdownParser.parse(markdown)
        
        // All lines with same tab position should have same indentation
        guard case .paragraph(let content) = doc.blocks.first else {
            Issue.record("Expected paragraph")
            return
        }
        
        var text = ""
        for element in content {
            switch element {
            case .text(let t):
                text += t
            case .softBreak, .hardBreak:
                text += "\n"
            default:
                break
            }
        }
        
        let lines = text.split(separator: "\n")
        for line in lines {
            #expect(line.starts(with: "    "), "Each line should start with 4 spaces (expanded tab)")
        }
    }
}