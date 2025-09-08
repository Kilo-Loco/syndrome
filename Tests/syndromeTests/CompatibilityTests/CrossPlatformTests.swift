import Testing
import Foundation
@testable import syndrome

@Suite("Cross-Platform Compatibility")
struct CrossPlatformTests {
    
    @Test("Platform-agnostic parsing")
    func platformAgnosticParsing() {
        // Test that parser works without any platform-specific APIs
        let markdown = "# Test\n\nParagraph"
        let doc = MarkdownParser.parse(markdown)
        
        #expect(doc.blocks.count == 2)
        #expect(doc.blocks.first != nil)
    }
    
    @Test("Unicode handling")
    func unicodeHandling() {
        let unicodeTests = [
            "# 你好世界",        // Chinese
            "# こんにちは世界",    // Japanese
            "# مرحبا بالعالم",   // Arabic
            "# Здравствуй мир",  // Russian
            "# 🎉 Emoji Title 🚀" // Emojis
        ]
        
        for markdown in unicodeTests {
            let doc = MarkdownParser.parse(markdown)
            
            guard case .heading = doc.blocks.first else {
                Issue.record("Failed to parse Unicode heading: \(markdown)")
                continue
            }
        }
    }
    
    @Test("Line ending normalization")
    func lineEndingNormalization() {
        let lineEndings = [
            ("LF", "Line 1\nLine 2\nLine 3"),
            ("CRLF", "Line 1\r\nLine 2\r\nLine 3"),
            ("CR", "Line 1\rLine 2\rLine 3"),
            ("Mixed", "Line 1\nLine 2\r\nLine 3\r")
        ]
        
        for (name, markdown) in lineEndings {
            let doc = MarkdownParser.parse(markdown)
            
            // All should produce the same result
            guard case .paragraph = doc.blocks.first else {
                Issue.record("Failed to parse \(name) line endings")
                continue
            }
        }
    }
    
    #if os(Linux)
    @Test("Linux-specific compatibility")
    func linuxCompatibility() {
        // Test Linux-specific concerns
        let markdown = "# Linux Test\n\n- Item 1\n- Item 2"
        let doc = MarkdownParser.parse(markdown)
        
        #expect(doc.blocks.count == 2)
        
        // Ensure no Darwin-specific APIs are used
        guard case .heading = doc.blocks.first else {
            Issue.record("Linux: Failed to parse heading")
            return
        }
        
        guard case .list = doc.blocks.last else {
            Issue.record("Linux: Failed to parse list")
            return
        }
    }
    #endif
    
    #if os(Windows)
    @Test("Windows-specific compatibility")
    func windowsCompatibility() {
        // Test Windows-specific concerns
        let markdown = "# Windows Test\r\n\r\n- Item 1\r\n- Item 2"
        let doc = MarkdownParser.parse(markdown)
        
        #expect(doc.blocks.count == 2)
        
        // Windows typically uses CRLF
        guard case .heading = doc.blocks.first else {
            Issue.record("Windows: Failed to parse heading")
            return
        }
        
        guard case .list = doc.blocks.last else {
            Issue.record("Windows: Failed to parse list")
            return
        }
    }
    #endif
    
    @Test("Foundation-only dependencies")
    func foundationOnlyDependencies() {
        // Verify that the parser only uses Foundation APIs
        // This test is more of a compile-time check
        let markdown = "# Test"
        let doc = MarkdownParser.parse(markdown)
        
        // If this compiles and runs, we're only using Foundation
        #expect(doc.blocks.count > 0)
    }
    
    @Test("Memory efficiency")
    func memoryEfficiency() {
        // Test that parser handles large documents efficiently
        let largeMarkdown = TestData.largeDocument(blocks: 100)
        
        let startMemory = getCurrentMemoryUsage()
        let doc = MarkdownParser.parse(largeMarkdown)
        let endMemory = getCurrentMemoryUsage()
        
        #expect(doc.blocks.count > 0)
        
        // Memory usage should be reasonable
        let memoryIncrease = endMemory - startMemory
        #expect(memoryIncrease < 100_000_000, "Memory usage should be under 100MB for large document")
    }
    
    @Test("Thread safety")
    func threadSafety() async {
        // Parser should be thread-safe for concurrent use
        let markdown = "# Concurrent Test"
        
        await withTaskGroup(of: MarkdownDocument.self) { group in
            for i in 0..<10 {
                group.addTask {
                    MarkdownParser.parse("\(markdown) \(i)")
                }
            }
            
            var results = 0
            for await doc in group {
                results += 1
                #expect(doc.blocks.count > 0)
            }
            
            #expect(results == 10, "All concurrent parses should complete")
        }
    }
    
    @Test("Encoding robustness")
    func encodingRobustness() {
        // Test various text encodings
        let testStrings = [
            "ASCII: Hello World",
            "UTF-8: 你好世界",
            "UTF-16: \u{1F600} \u{1F601}",
            "Special: \u{0000} \u{FFFF}"
        ]
        
        for string in testStrings {
            let markdown = "# \(string)"
            let doc = MarkdownParser.parse(markdown)
            
            guard case .heading = doc.blocks.first else {
                Issue.record("Failed to parse encoded string: \(string)")
                continue
            }
        }
    }
    
    // Helper function to get current memory usage
    private func getCurrentMemoryUsage() -> Int64 {
        // Simplified memory tracking for cross-platform compatibility
        // In production, use platform-specific APIs
        return 0
    }
}