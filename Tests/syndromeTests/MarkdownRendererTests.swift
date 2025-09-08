//
//  MarkdownRendererTests.swift
//  syndromeTests
//
//  Tests for the MarkdownRenderer functionality.
//

import XCTest
@testable import syndrome

#if canImport(AppKit) || canImport(UIKit)

final class MarkdownRendererTests: XCTestCase {
    
    func testBasicRendering() {
        let markdown = "# Hello World\n\nThis is a **bold** and *italic* test."
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        XCTAssertNotNil(attributed)
        XCTAssertGreaterThan(attributed.length, 0)
        
        // Check that the string contains the expected text
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("Hello World"))
        XCTAssertTrue(plainString.contains("This is a bold and italic test"))
    }
    
    func testHeadingRendering() {
        let markdown = """
        # Heading 1
        ## Heading 2
        ### Heading 3
        #### Heading 4
        ##### Heading 5
        ###### Heading 6
        """
        
        let document = MarkdownParser.parse(markdown)
        let renderer = MarkdownRenderer()
        let attributed = renderer.render(document)
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("Heading 1"))
        XCTAssertTrue(plainString.contains("Heading 2"))
        XCTAssertTrue(plainString.contains("Heading 3"))
        XCTAssertTrue(plainString.contains("Heading 4"))
        XCTAssertTrue(plainString.contains("Heading 5"))
        XCTAssertTrue(plainString.contains("Heading 6"))
    }
    
    func testListRendering() {
        let markdown = """
        - Item 1
        - Item 2
        - Item 3
        
        1. First
        2. Second
        3. Third
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("• Item 1"))
        XCTAssertTrue(plainString.contains("• Item 2"))
        XCTAssertTrue(plainString.contains("• Item 3"))
        XCTAssertTrue(plainString.contains("1. First"))
        XCTAssertTrue(plainString.contains("2. Second"))
        XCTAssertTrue(plainString.contains("3. Third"))
    }
    
    func testCodeBlockRendering() {
        let markdown = """
        ```swift
        func hello() {
            print("Hello, World!")
        }
        ```
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("func hello()"))
        XCTAssertTrue(plainString.contains("print(\"Hello, World!\")"))
    }
    
    func testInlineCodeRendering() {
        let markdown = "Use `let x = 42` to declare a constant."
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("let x = 42"))
    }
    
    func testLinkRendering() {
        let markdown = "Visit [Apple](https://apple.com) for more info."
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("Apple"))
        
        // Check if link attribute is present
        var hasLink = false
        attributed.enumerateAttribute(.link, in: NSRange(location: 0, length: attributed.length)) { value, range, stop in
            if let urlString = value as? String, urlString == "https://apple.com" {
                hasLink = true
            }
        }
        XCTAssertTrue(hasLink, "Link attribute should be present")
    }
    
    func testBlockquoteRendering() {
        let markdown = """
        > This is a quote
        > with multiple lines
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("This is a quote"))
        XCTAssertTrue(plainString.contains("with multiple lines"))
    }
    
    func testHorizontalRuleRendering() {
        let markdown = """
        Above
        
        ---
        
        Below
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("Above"))
        XCTAssertTrue(plainString.contains("━")) // Horizontal rule character
        XCTAssertTrue(plainString.contains("Below"))
    }
    
    func testImageRendering() {
        let markdown = "![Alt text](image.jpg)"
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("[Image: Alt text]"))
    }
    
    func testCustomOptions() {
        let markdown = "# Custom Test"
        
        var options = MarkdownRenderingOptions.default
        options.paragraphSpacing = 20.0
        options.listIndentation = 40.0
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString(options: options)
        
        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.string.contains("Custom Test"))
    }
    
    func testStringExtension() {
        let markdown = "**Bold** and *italic*"
        let attributed = markdown.markdownAttributedString()
        
        XCTAssertNotNil(attributed)
        XCTAssertTrue(attributed.string.contains("Bold and italic"))
    }
    
    func testEmphasisAndStrong() {
        let markdown = "This has **bold**, *italic*, and ***both***."
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("bold"))
        XCTAssertTrue(plainString.contains("italic"))
        XCTAssertTrue(plainString.contains("both"))
    }
    
    func testNestedLists() {
        let markdown = """
        - Item 1
          - Nested 1.1
          - Nested 1.2
        - Item 2
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("Item 1"))
        XCTAssertTrue(plainString.contains("Nested 1.1"))
        XCTAssertTrue(plainString.contains("Nested 1.2"))
        XCTAssertTrue(plainString.contains("Item 2"))
    }
    
    func testSoftAndHardBreaks() {
        let markdown = """
        Line 1\\
        Line 2
        
        Paragraph 2
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        XCTAssertTrue(plainString.contains("Line 1"))
        XCTAssertTrue(plainString.contains("Line 2"))
        XCTAssertTrue(plainString.contains("Paragraph 2"))
    }
    
    func testComplexDocument() {
        let markdown = """
        # syndrome Test
        
        This is a **comprehensive** test with various elements.
        
        ## Features
        
        - ✅ Lists with *emphasis*
        - ✅ Code like `let x = 42`
        - ✅ [Links](https://example.com)
        
        ### Code Example
        
        ```swift
        struct Example {
            let name: String
        }
        ```
        
        > "This is a blockquote with **bold** text."
        
        ---
        
        That's all folks!
        """
        
        let document = MarkdownParser.parse(markdown)
        let attributed = document.attributedString()
        
        let plainString = attributed.string
        
        // Check all major elements are present
        XCTAssertTrue(plainString.contains("syndrome Test"))
        XCTAssertTrue(plainString.contains("comprehensive"))
        XCTAssertTrue(plainString.contains("Features"))
        XCTAssertTrue(plainString.contains("✅"))
        XCTAssertTrue(plainString.contains("let x = 42"))
        XCTAssertTrue(plainString.contains("Links"))
        XCTAssertTrue(plainString.contains("struct Example"))
        XCTAssertTrue(plainString.contains("This is a blockquote"))
        XCTAssertTrue(plainString.contains("━")) // Horizontal rule
        XCTAssertTrue(plainString.contains("That's all folks!"))
    }
}

#endif // canImport(AppKit) || canImport(UIKit)