import Testing
import Foundation
@testable import syndrome

@Suite("Performance Benchmarks")
struct PerformanceBenchmarks {
    
    @Test("Parser performance with small document")
    func benchmarkSmallDocument() {
        let markdown = """
        # Heading
        
        This is a paragraph with **bold** and *italic* text.
        
        - List item 1
        - List item 2
        """
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<100 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0, "Small document parsing 100 times should take less than 1 second")
    }
    
    @Test("Parser performance with medium document")
    func benchmarkMediumDocument() {
        let markdown = String(repeating: """
        # Heading \(UUID().uuidString)
        
        This is a paragraph with **bold** and *italic* text, plus `inline code`.
        
        ## Subheading
        
        - List item with [link](https://example.com)
        - Another item with ![image](image.png)
        
        ```swift
        let code = "example"
        print(code)
        ```
        
        > Blockquote with multiple lines
        > and continued text
        
        ---
        
        
        """, count: 10)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<10 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 2.0, "Medium document parsing 10 times should take less than 2 seconds")
    }
    
    @Test("Parser performance with large document")
    func benchmarkLargeDocument() {
        let largeMarkdown = String(repeating: "# Heading\nParagraph text\n\n", count: 1000)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        _ = MarkdownParser.parse(largeMarkdown)
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0, "Large document (1000 blocks) should parse in less than 1 second")
    }
    
    @Test("Parser performance with complex inline elements")
    func benchmarkComplexInlineElements() {
        let markdown = """
        This is a paragraph with **bold**, *italic*, `code`, [link](url), ![image](img.png),
        and &copy; entities, plus \\* escaped characters. This pattern repeats many times.
        """ + String(repeating: " More **bold** and *italic* with `code` and [links](url).", count: 100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<10 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 2.0, "Complex inline parsing should complete in reasonable time")
    }
    
    @Test("Parser performance with deeply nested lists")
    func benchmarkNestedLists() {
        var markdown = ""
        for i in 0..<5 {
            markdown += String(repeating: "  ", count: i) + "- Item at level \(i)\n"
            for j in 0..<3 {
                markdown += String(repeating: "  ", count: i + 1) + "- Subitem \(j)\n"
            }
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<50 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0, "Nested list parsing should be efficient")
    }
    
    @Test("Tab expansion performance")
    func benchmarkTabExpansion() {
        let markdown = String(repeating: "\t\tHeading with tabs\n\t- List\twith\ttabs\n", count: 100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<10 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0, "Tab expansion should not significantly impact performance")
    }
    
    @Test("Entity processing performance")
    func benchmarkEntityProcessing() {
        let markdown = String(repeating: "&copy; &amp; &lt; &gt; &quot; &#169; &#x00A9; ", count: 100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<10 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0, "Entity processing should be efficient")
    }
    
    @Test("Escape processing performance")
    func benchmarkEscapeProcessing() {
        let markdown = String(repeating: "\\* \\_ \\` \\[ \\] \\! \\# \\+ \\- \\( \\) ", count: 100)
        
        let startTime = CFAbsoluteTimeGetCurrent()
        for _ in 0..<10 {
            _ = MarkdownParser.parse(markdown)
        }
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        #expect(timeElapsed < 1.0, "Escape processing should be efficient")
    }
}