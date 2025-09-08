//
//  MarkdownParserTests.swift
//  syndromeTests
//
//  Migrated from xamrock-appTests
//

import Testing
@testable import syndrome

@Suite("Markdown Parser Tests")
struct MarkdownParserTests {
    
    // MARK: - ATX Headings Tests
    
    @Suite("ATX Headings")
    struct ATXHeadingsTests {
        
        static let headingTestCases = [
            (markdown: "# Heading 1", expectedLevel: 1, expectedText: "Heading 1"),
            (markdown: "## Heading 2", expectedLevel: 2, expectedText: "Heading 2"),
            (markdown: "### Heading 3", expectedLevel: 3, expectedText: "Heading 3"),
            (markdown: "#### Heading 4", expectedLevel: 4, expectedText: "Heading 4"),
            (markdown: "##### Heading 5", expectedLevel: 5, expectedText: "Heading 5"),
            (markdown: "###### Heading 6", expectedLevel: 6, expectedText: "Heading 6")
        ]
        
        @Test("Parse heading levels", arguments: headingTestCases)
        func parseHeadingLevel(testCase: (markdown: String, expectedLevel: Int, expectedText: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let level, let content) = document.blocks[0] else {
                Issue.record("Expected heading block")
                return
            }
            
            #expect(level == testCase.expectedLevel)
            #expect(content.count == 1)
            
            if case .text(let text) = content[0] {
                #expect(text == testCase.expectedText)
            }
        }
        
        static let invalidHeadingCases = [
            "####### Too many hashes",
            "######## Eight hashes",
            "######### Nine hashes"
        ]
        
        @Test("Reject invalid headings", arguments: invalidHeadingCases)
        func rejectInvalidHeadings(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph for invalid heading")
                return
            }
            
            if case .text(let text) = content[0] {
                #expect(text == markdown)
            }
        }
        
        static let headingWhitespaceTestCases = [
            (markdown: "   # Spaced Heading   ", expectedLevel: 1, expectedText: "Spaced Heading"),
            (markdown: "\t## Tab Heading", expectedLevel: 2, expectedText: "Tab Heading"),
            (markdown: "### Mixed   Spacing  ###", expectedLevel: 3, expectedText: "Mixed   Spacing  ###")
        ]
        
        @Test("Handle heading whitespace", arguments: headingWhitespaceTestCases)
        func parseHeadingWithWhitespace(testCase: (markdown: String, expectedLevel: Int, expectedText: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let level, let content) = document.blocks[0] else {
                Issue.record("Expected heading block")
                return
            }
            
            #expect(level == testCase.expectedLevel)
            if case .text(let text) = content[0] {
                #expect(text == testCase.expectedText)
            }
        }
        
        @Test("Handle empty heading", arguments: [1, 2, 3, 4, 5, 6])
        func parseEmptyHeading(level: Int) {
            let hashes = String(repeating: "#", count: level)
            let document = MarkdownParser.parse(hashes)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let parsedLevel, let content) = document.blocks[0] else {
                Issue.record("Expected heading block")
                return
            }
            
            #expect(parsedLevel == level)
            #expect(content.isEmpty)
        }
    }
    
    // MARK: - Fenced Code Block Tests
    
    @Suite("Fenced Code Blocks")
    struct FencedCodeBlockTests {
        
        static let codeBlockTestCases = [
            (
                markdown: """
                ```swift
                print("Hello, World!")
                let x = 42
                ```
                """,
                expectedLanguage: "swift",
                expectedContent: "print(\"Hello, World!\")\nlet x = 42"
            ),
            (
                markdown: """
                ```python
                print("Python code")
                def hello():
                    return "world"
                ```
                """,
                expectedLanguage: "python",
                expectedContent: "print(\"Python code\")\ndef hello():\n    return \"world\""
            ),
            (
                markdown: """
                ```javascript
                console.log("JavaScript");
                ```
                """,
                expectedLanguage: "javascript",
                expectedContent: "console.log(\"JavaScript\");"
            )
        ]
        
        @Test("Parse code blocks with languages", arguments: codeBlockTestCases)
        func parseCodeBlockWithLanguage(testCase: (markdown: String, expectedLanguage: String, expectedContent: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .codeBlock(let info, let content) = document.blocks[0] else {
                Issue.record("Expected code block")
                return
            }
            
            #expect(info == testCase.expectedLanguage)
            #expect(content == testCase.expectedContent)
        }
        
        @Test("Parse code block without language")
        func parseCodeBlockWithoutLanguage() {
            let markdown = """
            ```
            Plain code block
            with no language
            ```
            """
            
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.count == 1)
            
            guard case .codeBlock(let info, let content) = document.blocks[0] else {
                Issue.record("Expected code block")
                return
            }
            
            #expect(info == nil)
            #expect(content == "Plain code block\nwith no language")
        }
        
        static let fenceTypes = ["```", "~~~"]
        
        @Test("Parse different fence types", arguments: fenceTypes)
        func parseDifferentFenceTypes(fence: String) {
            let markdown = """
            \(fence)python
            print("Test")
            \(fence)
            """
            
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.count == 1)
            
            guard case .codeBlock(let info, let content) = document.blocks[0] else {
                Issue.record("Expected code block")
                return
            }
            
            #expect(info == "python")
            #expect(content == "print(\"Test\")")
        }
    }
    
    // MARK: - List Tests
    
    @Suite("Lists")
    struct ListTests {
        
        static let unorderedMarkers: [Character] = ["-", "*", "+"]
        
        @Test("Parse unordered list markers", arguments: unorderedMarkers)
        func parseUnorderedListMarkers(marker: Character) {
            let markdown = """
            \(marker) Item 1
            \(marker) Item 2
            \(marker) Item 3
            """
            
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.count == 1)
            
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block")
                return
            }
            
            guard case .unordered(let parsedMarker) = type else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(parsedMarker == marker)
            #expect(items.count == 3)
        }
        
        static let orderedDelimiters: [Character] = [".", ")"]
        
        @Test("Parse ordered list delimiters", arguments: orderedDelimiters)
        func parseOrderedListDelimiters(delimiter: Character) {
            let markdown = """
            1\(delimiter) First item
            2\(delimiter) Second item
            3\(delimiter) Third item
            """
            
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.count == 1)
            
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block")
                return
            }
            
            guard case .ordered(let startNumber, let parsedDelimiter) = type else {
                Issue.record("Expected ordered list")
                return
            }
            
            #expect(startNumber == 1)
            #expect(parsedDelimiter == delimiter)
            #expect(items.count == 3)
        }
        
        static let startNumbers = [1, 5, 10, 99]
        
        @Test("Parse ordered list start numbers", arguments: startNumbers)
        func parseOrderedListStartNumbers(startNumber: Int) {
            let markdown = """
            \(startNumber). Item at \(startNumber)
            \(startNumber + 1). Next item
            \(startNumber + 2). Third item
            """
            
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.count == 1)
            
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block")
                return
            }
            
            guard case .ordered(let parsedStartNumber, let delimiter) = type else {
                Issue.record("Expected ordered list")
                return
            }
            
            #expect(parsedStartNumber == startNumber)
            #expect(delimiter == ".")
            #expect(items.count == 3)
        }
    }
    
    // MARK: - Blockquote Tests
    
    @Suite("Blockquotes")
    struct BlockquoteTests {
        
        static let simpleBlockquotes = [
            "> Simple blockquote",
            "> Blockquote with **bold** text",
            "> Blockquote with *italic* text",
            "> Blockquote with `code`",
            "> Blockquote with [link](url)"
        ]
        
        @Test("Parse simple blockquotes", arguments: simpleBlockquotes)
        func parseSimpleBlockquotes(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .blockquote(let content) = document.blocks[0] else {
                Issue.record("Expected blockquote block")
                return
            }
            
            #expect(content.count >= 1)
        }
        
        @Test("Parse multiline blockquote")
        func parseMultilineBlockquote() {
            let markdown = """
            > This is a blockquote
            > with multiple lines
            > spanning several rows
            """
            
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.count == 1)
            
            guard case .blockquote(let content) = document.blocks[0] else {
                Issue.record("Expected blockquote block")
                return
            }
            
            #expect(content.count >= 1)
        }
    }
    
    // MARK: - Horizontal Rule Tests
    
    @Suite("Horizontal Rules")
    struct HorizontalRuleTests {
        
        static let validHorizontalRules = [
            "---",
            "***",
            "___",
            "- - -",
            "* * *",
            "_ _ _",
            "----",
            "****",
            "____",
            "----------"
        ]
        
        @Test("Parse valid horizontal rules", arguments: validHorizontalRules)
        func parseValidHorizontalRules(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .horizontalRule = document.blocks[0] else {
                Issue.record("Expected horizontal rule")
                return
            }
        }
        
        @Test("Reject invalid non-empty horizontal rules")
        func rejectInvalidNonEmptyHorizontalRules() {
            let markdown = "--"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1, "Expected 1 block for '\(markdown)', got \(document.blocks.count)")
            
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph for invalid horizontal rule '\(markdown)' but got \(document.blocks[0]). All blocks: \(document.blocks)")
                return
            }
            
            #expect(content.count > 0, "Paragraph content is empty for input '\(markdown)'. Content: \(content)")
            
            guard case .text(let text) = content[0] else {
                Issue.record("First content element is not text for '\(markdown)': \(content[0]). Full content: \(content)")
                return
            }
            
            #expect(text == markdown, "Text content '\(text)' doesn't match input '\(markdown)'")
        }
        
        @Test("Test abc parameterized style")
        func testAbcParameterizedStyle() {
            let markdown = "abc"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1, "Expected 1 block for '\(markdown)', got \(document.blocks.count)")
            
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph for invalid horizontal rule '\(markdown)' but got \(document.blocks[0]). All blocks: \(document.blocks)")
                return
            }
            
            #expect(content.count > 0, "Paragraph content is empty for input '\(markdown)'. Content: \(content)")
            
            guard case .text(let text) = content[0] else {
                Issue.record("First content element is not text for '\(markdown)': \(content[0]). Full content: \(content)")
                return
            }
            
            #expect(text == markdown, "Text content '\(text)' doesn't match input '\(markdown)'")
        }
        
        @Test("Mixed characters with spaces creates list")
        func testMixedCharactersWithSpacesCreatesList() {
            // "- * -" is correctly interpreted as an unordered list item with content "* -"
            let document = MarkdownParser.parse("- * -")
            #expect(document.blocks.count == 1, "Expected 1 block")
            
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block, got: \(document.blocks[0])")
                return
            }
            
            guard case .unordered(let marker) = type else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker == "-", "Expected dash marker")
            #expect(items.count == 1, "Expected 1 list item")
        }
        
        @Test("Reject empty string as horizontal rule")
        func rejectEmptyStringAsHorizontalRule() {
            let document = MarkdownParser.parse("")
            #expect(document.blocks.isEmpty, "Empty string should result in no blocks")
        }
    }
    
    // MARK: - Inline Element Tests
    
    @Suite("Strong Emphasis (Bold)")
    struct StrongEmphasisTests {
        
        static let boldTestCases = [
            (markdown: "**bold text**", expectedText: "bold text"),
            (markdown: "__also bold__", expectedText: "also bold"),
            (markdown: "**bold with spaces**", expectedText: "bold with spaces"),
            (markdown: "__underscores work too__", expectedText: "underscores work too")
        ]
        
        @Test("Parse bold text", arguments: boldTestCases)
        func parseBoldText(testCase: (markdown: String, expectedText: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .strongEmphasis(let inner) = content[0] else {
                Issue.record("Expected strong emphasis")
                return
            }
            
            if case .text(let text) = inner[0] {
                #expect(text == testCase.expectedText)
            }
        }
        
        static let unclosedBoldCases = [
            "**unclosed bold",
            "__unclosed underscore bold",
            "**almost closed*",
            "__almost closed_"
        ]
        
        
        @Test("Handle unclosed bold", arguments: unclosedBoldCases)
        func handleUnclosedBold(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            // Should be treated as regular text - but may be split across multiple elements
            let reconstructed = content.map { element in
                switch element {
                case .text(let text): return text
                case .strongEmphasis(let inner):
                    return "**" + inner.compactMap { if case .text(let t) = $0 { return t } else { return nil } }.joined() + "**"
                case .emphasis(let inner):
                    return "*" + inner.compactMap { if case .text(let t) = $0 { return t } else { return nil } }.joined() + "*"
                default: return "[\(element)]"
                }
            }.joined()
            
            #expect(reconstructed == markdown)
        }
    }
    
    @Suite("Emphasis (Italic)")
    struct EmphasisTests {
        
        static let italicTestCases = [
            (markdown: "*italic text*", expectedText: "italic text"),
            (markdown: "_also italic_", expectedText: "also italic"),
            (markdown: "*with spaces*", expectedText: "with spaces"),
            (markdown: "_underscores work_", expectedText: "underscores work")
        ]
        
        @Test("Parse italic text", arguments: italicTestCases)
        func parseItalicText(testCase: (markdown: String, expectedText: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .emphasis(let inner) = content[0] else {
                Issue.record("Expected emphasis")
                return
            }
            
            if case .text(let text) = inner[0] {
                #expect(text == testCase.expectedText)
            }
        }
    }
    
    @Suite("Inline Code")
    struct InlineCodeTests {
        
        static let codeTestCases = [
            (markdown: "`code`", expectedText: "code"),
            (markdown: "`console.log()`", expectedText: "console.log()"),
            (markdown: "`code with spaces`", expectedText: "code with spaces"),
            (markdown: "`let x = 42`", expectedText: "let x = 42")
        ]
        
        @Test("Parse inline code", arguments: codeTestCases)
        func parseInlineCode(testCase: (markdown: String, expectedText: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .code(let code) = content[0] else {
                Issue.record("Expected code element")
                return
            }
            
            #expect(code == testCase.expectedText)
        }
    }
    
    @Suite("Links")
    struct LinkTests {
        
        static let linkTestCases = [
            (markdown: "[OpenAI](https://openai.com)", expectedText: "OpenAI", expectedURL: "https://openai.com"),
            (markdown: "[Google](https://google.com)", expectedText: "Google", expectedURL: "https://google.com"),
            (markdown: "[Local](../local/path)", expectedText: "Local", expectedURL: "../local/path"),
            (markdown: "[Empty URL]()", expectedText: "Empty URL", expectedURL: "")
        ]
        
        @Test("Parse links", arguments: linkTestCases)
        func parseLinks(testCase: (markdown: String, expectedText: String, expectedURL: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .link(let text, let url, let title) = content[0] else {
                Issue.record("Expected link element")
                return
            }
            
            if case .text(let linkText) = text[0] {
                #expect(linkText == testCase.expectedText)
            }
            #expect(url == testCase.expectedURL)
            #expect(title == nil)
        }
    }
    
    @Suite("Images")
    struct ImageTests {
        
        static let imageTestCases = [
            (markdown: "![Alt text](image.png)", expectedAlt: "Alt text", expectedURL: "image.png"),
            (markdown: "![Logo](https://example.com/logo.png)", expectedAlt: "Logo", expectedURL: "https://example.com/logo.png"),
            (markdown: "![](no-alt.jpg)", expectedAlt: "", expectedURL: "no-alt.jpg"),
            (markdown: "![Screenshot](../assets/screenshot.png)", expectedAlt: "Screenshot", expectedURL: "../assets/screenshot.png")
        ]
        
        @Test("Parse images", arguments: imageTestCases)
        func parseImages(testCase: (markdown: String, expectedAlt: String, expectedURL: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .image(let alt, let url, let title) = content[0] else {
                Issue.record("Expected image element")
                return
            }
            
            if testCase.expectedAlt.isEmpty {
                #expect(alt.isEmpty)
            } else {
                if case .text(let altText) = alt[0] {
                    #expect(altText == testCase.expectedAlt)
                }
            }
            #expect(url == testCase.expectedURL)
            #expect(title == nil)
        }
    }
    
    // MARK: - Edge Cases and Complex Tests
    
    @Suite("Edge Cases")
    struct EdgeCaseTests {
        
        static let emptyDocuments = ["", "   ", "\n\n", "   \n\n   \n  "]
        
        @Test("Parse empty documents", arguments: emptyDocuments)
        func parseEmptyDocuments(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            #expect(document.blocks.isEmpty)
        }
        
        static let specialCharacterCases = [
            "Text with émojis 🎉 and special chars",
            "Ñoñó spëcial çhars everywhere",
            "Unicode: α β γ δ ε ζ η θ",
            "Mixed: café naïve résumé"
        ]
        
        @Test("Handle special characters", arguments: specialCharacterCases)
        func handleSpecialCharacters(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            if case .text(let text) = content[0] {
                #expect(text == markdown)
            }
        }
        

        @Test("Test empty string horizontal rule rejection")
        func testEmptyStringHorizontalRuleRejection() {
            let document = MarkdownParser.parse("")
            #expect(document.blocks.isEmpty, "Empty string should result in no blocks")
        }
        
        @Test("Test abc horizontal rule rejection")
        func testAbcHorizontalRuleRejection() {
            let document = MarkdownParser.parse("abc")
            #expect(document.blocks.count == 1, "Expected 1 block")
            
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph block")
                return
            }
            
            #expect(content.count == 1, "Expected 1 content element")
            
            guard case .text(let text) = content[0] else {
                Issue.record("Expected text element")
                return
            }
            
            #expect(text == "abc", "Expected 'abc' text")
        }
        
        @Test("Test mixed characters horizontal rule rejection")
        func testMixedCharactersHorizontalRuleRejection() {
            let document = MarkdownParser.parse("-*-")
            #expect(document.blocks.count == 1, "Expected 1 block")
            
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph block, got: \(document.blocks[0])")
                return
            }
            
            // The parser might interpret this as "-" + "*" (emphasis) + "-"
            // Let's see what we actually get
            if content.count == 1 {
                if case .text(let text) = content[0] {
                    #expect(text == "-*-", "Expected '-*-' text, got: '\(text)'")
                } else {
                    Issue.record("Single content element is not text: \(content[0])")
                }
            } else {
                // If it's parsed as multiple elements (text + emphasis + text), that's also acceptable
                // as long as the content semantically represents "-*-"
                var reconstructed = ""
                for element in content {
                    switch element {
                    case .text(let text):
                        reconstructed += text
                    case .emphasis(let emphContent):
                        reconstructed += "*"
                        for emphElement in emphContent {
                            if case .text(let emphText) = emphElement {
                                reconstructed += emphText
                            }
                        }
                        reconstructed += "*"
                    case .strongEmphasis(let strongContent):
                        reconstructed += "**"
                        for strongElement in strongContent {
                            if case .text(let strongText) = strongElement {
                                reconstructed += strongText
                            }
                        }
                        reconstructed += "**"
                    default:
                        Issue.record("Unexpected inline element: \(element)")
                    }
                }
                
                Issue.record("Multiple content elements found for '-*-': \(content). Reconstructed: '\(reconstructed)'")
            }
        }
        
        @Test("Test spaced dash horizontal rule rejection")
        func testSpacedDashHorizontalRuleRejection() {
            let document = MarkdownParser.parse("- * -")
            #expect(document.blocks.count == 1, "Expected 1 block")
            
            // The parser correctly identifies this as a list item, not a paragraph
            // "- * -" in Markdown is a valid unordered list with content "* -"
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block, got: \(document.blocks[0])")
                return
            }
            
            guard case .unordered(let marker) = type else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker == "-", "Expected dash marker")
            #expect(items.count == 1, "Expected 1 list item")
            
            // The content of the list item should be "* -"
            guard case .paragraph(let itemContent) = items[0].content[0] else {
                Issue.record("Expected paragraph in list item")
                return
            }
            
            guard case .text(let text) = itemContent[0] else {
                Issue.record("Expected text in list item")
                return
            }
            
            #expect(text == "* -", "Expected list item text to be '* -'")
        }
        
        @Test("Test individual complex document elements")
        func testIndividualComplexDocumentElements() {
            // Test each element type individually first
            
            // 1. Heading
            let heading = MarkdownParser.parse("# Main Title")
            #expect(heading.blocks.count == 1)
            guard case .heading(let level, _) = heading.blocks[0] else {
                Issue.record("Failed to parse heading")
                return
            }
            #expect(level == 1)
            
            // 2. Paragraph with formatting
            let paragraph = MarkdownParser.parse("This is a paragraph with **bold** and *italic* text, plus `code`.")
            #expect(paragraph.blocks.count == 1)
            guard case .paragraph(let content) = paragraph.blocks[0] else {
                Issue.record("Failed to parse paragraph")
                return
            }
            #expect(content.count >= 6) // Should have multiple inline elements
            
            // 3. Unordered list
            let unorderedList = """
            - Unordered item with **bold**
            - Another item with [link](url)
            - Item with `code`
            """
            let listDoc = MarkdownParser.parse(unorderedList)
            #expect(listDoc.blocks.count == 1)
            guard case .list(let items, let type) = listDoc.blocks[0] else {
                Issue.record("Failed to parse unordered list")
                return
            }
            #expect(items.count == 3)
            guard case .unordered(let marker) = type else {
                Issue.record("Expected unordered list type")
                return
            }
            #expect(marker == "-")
            
            // 4. Ordered list
            let orderedList = """
            1. Ordered item
            2. Another ordered item
            """
            let orderedDoc = MarkdownParser.parse(orderedList)
            #expect(orderedDoc.blocks.count == 1)
            guard case .list(let orderedItems, let orderedType) = orderedDoc.blocks[0] else {
                Issue.record("Failed to parse ordered list")
                return
            }
            #expect(orderedItems.count == 2)
            
            // 5. Blockquote
            let blockquote = MarkdownParser.parse("> Blockquote with **formatting**")
            #expect(blockquote.blocks.count == 1)
            guard case .blockquote(let quoteContent) = blockquote.blocks[0] else {
                Issue.record("Failed to parse blockquote")
                return
            }
            #expect(quoteContent.count >= 1)
            
            // 6. Code block
            let codeBlock = """
            ```swift
            // Code block
            print("Hello")
            ```
            """
            let codeDoc = MarkdownParser.parse(codeBlock)
            #expect(codeDoc.blocks.count == 1)
            guard case .codeBlock(let info, let code) = codeDoc.blocks[0] else {
                Issue.record("Failed to parse code block")
                return
            }
            #expect(info == "swift")
            #expect(code.contains("print"))
            
            // 7. Horizontal rule
            let hr = MarkdownParser.parse("---")
            #expect(hr.blocks.count == 1)
            guard case .horizontalRule = hr.blocks[0] else {
                Issue.record("Failed to parse horizontal rule")
                return
            }
        }

        @Test("Parse complex document")
        func parseComplexDocument() {
            let markdown = """
            # Main Title
            
            This is a paragraph with **bold** and *italic* text, plus `code`.
            
            ## Lists Section
            
            - Unordered item with **bold**
            - Another item with [link](url)
            - Item with `code`
            
            1. Ordered item
            2. Another ordered item
            
            > Blockquote with **formatting**
            
            ```swift
            // Code block
            print("Hello")
            ```
            
            ---
            
            Final paragraph.
            """
            
            let document = MarkdownParser.parse(markdown)
            
            // Create detailed failure message
            var blockDescriptions: [String] = []
            for (index, block) in document.blocks.enumerated() {
                switch block {
                case .heading(let level, _):
                    blockDescriptions.append("Block \(index): Heading level \(level)")
                case .paragraph(_):
                    blockDescriptions.append("Block \(index): Paragraph")
                case .codeBlock(let info, _):
                    blockDescriptions.append("Block \(index): Code block (\(info ?? "no language"))")
                case .list(let items, let type):
                    switch type {
                    case .unordered(let marker):
                        blockDescriptions.append("Block \(index): Unordered list (\(marker), \(items.count) items)")
                    case .ordered(let start, let delimiter):
                        blockDescriptions.append("Block \(index): Ordered list (\(start)\(delimiter), \(items.count) items)")
                    }
                case .blockquote(_):
                    blockDescriptions.append("Block \(index): Blockquote")
                case .horizontalRule:
                    blockDescriptions.append("Block \(index): Horizontal rule")
                case .htmlBlock(_):
                    blockDescriptions.append("Block \(index): HTML block")
                }
            }
            
            let actualStructure = blockDescriptions.joined(separator: "; ")
            
            if document.blocks.count != 9 {
                Issue.record("Expected 9 blocks but got \(document.blocks.count). Structure: \(actualStructure)")
                return
            }
            
            // Verify first and last blocks
            guard case .heading(let level, _) = document.blocks[0] else {
                Issue.record("Expected heading as first block. Structure: \(actualStructure)")
                return
            }
            #expect(level == 1)
            
            guard case .paragraph(_) = document.blocks[8] else {
                Issue.record("Expected paragraph as last block. Structure: \(actualStructure)")
                return
            }
        }
    }
    
    // MARK: - Backslash Escape Tests
    
    @Suite("Backslash Escapes")
    struct BackslashEscapeTests {
        
        static let basicEscapeTestCases = [
            (markdown: "\\*not italic\\*", expected: "*not italic*"),
            (markdown: "\\_not emphasis\\_", expected: "_not emphasis_"),
            (markdown: "\\`not code\\`", expected: "`not code`"),
            (markdown: "\\[not a link\\]", expected: "[not a link]"),
            (markdown: "\\!not an image", expected: "!not an image"),
            (markdown: "\\\\double backslash", expected: "\\double backslash"),
            (markdown: "\\# not a heading", expected: "# not a heading"),
            (markdown: "\\+ not a list", expected: "+ not a list"),
            (markdown: "\\- not a list", expected: "- not a list")
        ]
        
        @Test("Parse basic escapes", arguments: basicEscapeTestCases)
        func parseBasicEscapes(testCase: (markdown: String, expected: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == testCase.expected)
        }
        
        @Test("Escape within bold text")
        func escapeWithinBoldText() {
            let markdown = "**bold with \\* asterisk**"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .strongEmphasis(let innerContent) = content[0] else {
                Issue.record("Expected strong emphasis")
                return
            }
            
            let actualText = innerContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "bold with * asterisk")
        }
        
        @Test("Escape within italic text")
        func escapeWithinItalicText() {
            let markdown = "*italic with \\_ underscore*"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .emphasis(let innerContent) = content[0] else {
                Issue.record("Expected emphasis")
                return
            }
            
            let actualText = innerContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "italic with _ underscore")
        }
        
        @Test("Multiple consecutive escapes")
        func multipleConsecutiveEscapes() {
            let markdown = "\\*\\*not bold\\*\\*"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "**not bold**")
        }
        
        @Test("Trailing backslash")
        func trailingBackslash() {
            let markdown = "text with trailing backslash\\"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "text with trailing backslash\\")
        }
        
        @Test("Non-special character escape")
        func nonSpecialCharacterEscape() {
            let markdown = "\\a normal text"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "\\a normal text")
        }
        
        @Test("Escape in heading")
        func escapeInHeading() {
            let markdown = "# Heading with \\* asterisk"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let level, let content) = document.blocks[0] else {
                Issue.record("Expected heading")
                return
            }
            
            #expect(level == 1)
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Heading with * asterisk")
        }
        
        @Test("Escape in list item")
        func escapeInListItem() {
            let markdown = "- Item with \\* asterisk"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list")
                return
            }
            
            guard case .unordered(let marker) = type else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker == "-")
            #expect(items.count == 1)
            
            guard case .paragraph(let itemContent) = items[0].content[0] else {
                Issue.record("Expected paragraph in list item")
                return
            }
            
            let actualText = itemContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Item with * asterisk")
        }
        
        @Test("Escape in blockquote")
        func escapeInBlockquote() {
            let markdown = "> Quote with \\* asterisk"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .blockquote(let content) = document.blocks[0] else {
                Issue.record("Expected blockquote")
                return
            }
            
            #expect(content.count == 1)
            guard case .paragraph(let paragraphContent) = content[0] else {
                Issue.record("Expected paragraph in blockquote")
                return
            }
            
            let actualText = paragraphContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Quote with * asterisk")
        }
        
        @Test("Escape parentheses in text")
        func escapeParenthesesInText() {
            let markdown = "Text with \\( and \\) parentheses"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Text with ( and ) parentheses")
        }
    }
    
    // MARK: - HTML Entity Tests
    
    @Suite("HTML Entities")
    struct HTMLEntityTests {
        
        static let coreEntityTestCases = [
            (markdown: "&amp;", expected: "&"),
            (markdown: "&lt;div&gt;", expected: "<div>"),
            (markdown: "&quot;quoted&quot;", expected: "\"quoted\""),
            (markdown: "&apos;apostrophe&apos;", expected: "'apostrophe'"),
            (markdown: "AT&amp;T", expected: "AT&T")
        ]
        
        @Test("Parse core HTML entities", arguments: coreEntityTestCases)
        func parseCoreHTMLEntities(testCase: (markdown: String, expected: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == testCase.expected)
        }
        
        static let namedEntityTestCases = [
            (markdown: "&copy; 2024", expected: "© 2024"),
            (markdown: "&reg; trademark", expected: "® trademark"),
            (markdown: "&trade; symbol", expected: "™ symbol"),
            (markdown: "&mdash;dash&mdash;", expected: "—dash—"),
            (markdown: "&ndash;en&ndash;", expected: "–en–"),
            (markdown: "&hellip;", expected: "…"),
            (markdown: "word&nbsp;word", expected: "word\u{00A0}word")
        ]
        
        @Test("Parse named entities", arguments: namedEntityTestCases)
        func parseNamedEntities(testCase: (markdown: String, expected: String)) {
            let document = MarkdownParser.parse(testCase.markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == testCase.expected)
        }
        
        @Test("Parse decimal numeric references")
        func parseDecimalNumericReferences() {
            let markdown = "&#169; &#174; &#8482;"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "© ® ™")
        }
        
        @Test("Parse hexadecimal numeric references")
        func parseHexadecimalNumericReferences() {
            let markdown = "&#x00A9; &#x00AE; &#x2122;"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "© ® ™")
        }
        
        @Test("Handle invalid entities")
        func handleInvalidEntities() {
            let markdown = "&invalid; &amp &notanentity;"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "&invalid; &amp &notanentity;")
        }
        
        @Test("Entities in bold text")
        func entitiesInBoldText() {
            let markdown = "**&copy; bold copyright**"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .strongEmphasis(let innerContent) = content[0] else {
                Issue.record("Expected strong emphasis")
                return
            }
            
            let actualText = innerContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "© bold copyright")
        }
        
        @Test("Entities in italic text")
        func entitiesInItalicText() {
            let markdown = "*&reg; italic registered*"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .emphasis(let innerContent) = content[0] else {
                Issue.record("Expected emphasis")
                return
            }
            
            let actualText = innerContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "® italic registered")
        }
        
        @Test("Entities NOT processed in inline code")
        func entitiesNotProcessedInInlineCode() {
            let markdown = "`code &amp; more`"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            guard case .code(let code) = content[0] else {
                Issue.record("Expected code element")
                return
            }
            
            #expect(code == "code &amp; more")
        }
        
        @Test("Entities in headings")
        func entitiesInHeadings() {
            let markdown = "# Heading &copy; 2024"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let level, let content) = document.blocks[0] else {
                Issue.record("Expected heading")
                return
            }
            
            #expect(level == 1)
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Heading © 2024")
        }
        
        @Test("Entities in list items")
        func entitiesInListItems() {
            let markdown = "- Item with &trade; symbol"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list")
                return
            }
            
            guard case .unordered(let marker) = type else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker == "-")
            #expect(items.count == 1)
            
            guard case .paragraph(let itemContent) = items[0].content[0] else {
                Issue.record("Expected paragraph in list item")
                return
            }
            
            let actualText = itemContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Item with ™ symbol")
        }
        
        @Test("Entities in blockquotes")
        func entitiesInBlockquotes() {
            let markdown = "> Quote with &mdash; dash"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .blockquote(let content) = document.blocks[0] else {
                Issue.record("Expected blockquote")
                return
            }
            
            #expect(content.count == 1)
            guard case .paragraph(let paragraphContent) = content[0] else {
                Issue.record("Expected paragraph in blockquote")
                return
            }
            
            let actualText = paragraphContent.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "Quote with — dash")
        }
        
        @Test("Multiple consecutive entities")
        func multipleConsecutiveEntities() {
            let markdown = "&lt;&gt;&amp;"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let actualText = content.map { element in
                switch element {
                case .text(let text):
                    return text
                default:
                    return ""
                }
            }.joined()
            
            #expect(actualText == "<>&")
        }
        
        @Test("Entities NOT processed in fenced code blocks")
        func entitiesNotProcessedInFencedCodeBlocks() {
            let markdown = """
            ```
            code &amp; entities &lt;div&gt;
            ```
            """
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .codeBlock(let info, let content) = document.blocks[0] else {
                Issue.record("Expected code block")
                return
            }
            
            #expect(info == nil)
            #expect(content == "code &amp; entities &lt;div&gt;")
        }
    }
    
    // MARK: - Tab Handling Tests
    
    @Suite("Tab Handling")
    struct TabHandlingTests {
        
        @Test("Parse list with tab after marker")
        func parseListWithTabAfterMarker() {
            let markdown = "-\tItem with tab\n-\tAnother item"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block")
                return
            }
            
            guard case .unordered(let marker) = type else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker == "-")
            #expect(items.count == 2)
            
            // Check first item
            guard case .paragraph(let content1) = items[0].content[0] else {
                Issue.record("Expected paragraph in first list item")
                return
            }
            
            let text1 = content1.compactMap { element in
                if case .text(let text) = element { return text } else { return nil }
            }.joined()
            #expect(text1 == "Item with tab")
            
            // Check second item
            guard case .paragraph(let content2) = items[1].content[0] else {
                Issue.record("Expected paragraph in second list item")
                return
            }
            
            let text2 = content2.compactMap { element in
                if case .text(let text) = element { return text } else { return nil }
            }.joined()
            #expect(text2 == "Another item")
        }
        
        @Test("Parse heading with tab indentation")
        func parseHeadingWithTabIndentation() {
            let markdown = "\t# Heading with tab"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let level, let content) = document.blocks[0] else {
                Issue.record("Expected heading block")
                return
            }
            
            #expect(level == 1)
            
            let text = content.compactMap { element in
                if case .text(let text) = element { return text } else { return nil }
            }.joined()
            #expect(text == "Heading with tab")
        }
        
        @Test("Parse heading with tab after marker")
        func parseHeadingWithTabAfterMarker() {
            let markdown = "#\tHeading with tab"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .heading(let level, let content) = document.blocks[0] else {
                Issue.record("Expected heading block")
                return
            }
            
            #expect(level == 1)
            
            let text = content.compactMap { element in
                if case .text(let text) = element { return text } else { return nil }
            }.joined()
            #expect(text == "Heading with tab")
        }
        
        @Test("Mixed tabs and spaces in list")
        func mixedTabsAndSpacesInList() {
            let markdown = """
            -\tTab item
            - Space item
            *\tAnother tab
            * Another space
            """
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 2)
            
            // First list (dash marker)
            guard case .list(let items1, let type1) = document.blocks[0] else {
                Issue.record("Expected first list block")
                return
            }
            
            guard case .unordered(let marker1) = type1 else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker1 == "-")
            #expect(items1.count == 2)
            
            // Second list (asterisk marker)
            guard case .list(let items2, let type2) = document.blocks[1] else {
                Issue.record("Expected second list block")
                return
            }
            
            guard case .unordered(let marker2) = type2 else {
                Issue.record("Expected unordered list")
                return
            }
            
            #expect(marker2 == "*")
            #expect(items2.count == 2)
        }
        
        @Test("Tab expansion in code block")
        func tabExpansionInCodeBlock() {
            let markdown = """
            ```
            \tindented code
            \t\tdouble indented
            ```
            """
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .codeBlock(let info, let content) = document.blocks[0] else {
                Issue.record("Expected code block")
                return
            }
            
            #expect(info == nil)
            // Tabs should be expanded to spaces
            #expect(content.contains("    indented code"))
            #expect(content.contains("        double indented"))
        }
        
        @Test("Tab in paragraph text")
        func tabInParagraphText() {
            let markdown = "Text with\ttab character"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let text = content.compactMap { element in
                if case .text(let text) = element { return text } else { return nil }
            }.joined()
            
            // Tab should be expanded to spaces
            #expect(text.contains("Text with"))
            #expect(text.contains("tab character"))
            #expect(!text.contains("\t"))
        }
        
        @Test("Ordered list with tab after delimiter")
        func orderedListWithTabAfterDelimiter() {
            let markdown = "1.\tFirst item\n2.\tSecond item"
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .list(let items, let type) = document.blocks[0] else {
                Issue.record("Expected list block")
                return
            }
            
            guard case .ordered(let startNumber, let delimiter) = type else {
                Issue.record("Expected ordered list")
                return
            }
            
            #expect(startNumber == 1)
            #expect(delimiter == ".")
            #expect(items.count == 2)
        }
        
        @Test("Tab expansion preserves column alignment")
        func tabExpansionPreservesColumnAlignment() {
            // Test that tabs expand to next 4-character boundary
            let markdown = """
            a\tb
            ab\tc
            abc\td
            abcd\te
            """
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            let text = content.compactMap { element in
                if case .text(let text) = element { return text } else { return nil }
            }.joined()
            
            // Verify proper tab expansion
            #expect(text.contains("a   b"))  // 'a' at column 0, tab expands to column 4
            #expect(text.contains("ab  c"))  // 'ab' at column 0-1, tab expands to column 4
            #expect(text.contains("abc d"))  // 'abc' at column 0-2, tab expands to column 4
            #expect(text.contains("abcd    e"))  // 'abcd' at column 0-3, tab expands to column 8
        }
    }
    
    // MARK: - Mixed Content Tests
    
    @Suite("Mixed Content")
    struct MixedContentTests {
        
        static let paragraphMixedCases = [
            "Text with **bold**, *italic*, `code`, and [link](url).",
            "More **bold** and _italic_ formatting together.",
            "Code `function()` and **bold** text mixed.",
            "Links [Google](https://google.com) with **bold** text."
        ]
        
        @Test("Parse paragraphs with mixed inline elements", arguments: paragraphMixedCases)
        func parseParagraphsWithMixedInlineElements(markdown: String) {
            let document = MarkdownParser.parse(markdown)
            
            #expect(document.blocks.count == 1)
            guard case .paragraph(let content) = document.blocks[0] else {
                Issue.record("Expected paragraph")
                return
            }
            
            #expect(content.count > 1, "Expected multiple inline elements")
            
            // Verify we have different types of inline elements
            let hasText = content.contains { if case .text(_) = $0 { return true }; return false }
            let hasFormatting = content.contains { element in
                switch element {
                case .strongEmphasis(_), .emphasis(_), .code(_), .link(_, _, _):
                    return true
                default:
                    return false
                }
            }
            
            #expect(hasText, "Should contain text elements")
            #expect(hasFormatting, "Should contain formatting elements")
        }
    }
}
