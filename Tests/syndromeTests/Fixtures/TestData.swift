import Foundation

enum TestData {
    
    // MARK: - Simple Documents
    
    static let simpleHeading = "# Title"
    
    static let simpleParagraph = "This is a paragraph."
    
    static let simpleList = """
    - Item 1
    - Item 2
    - Item 3
    """
    
    // MARK: - Complex Documents
    
    static let complexDocument = """
    # Main Title
    
    This is a paragraph with **bold** and *italic* text, plus `inline code`.
    
    ## Features
    
    - First feature with [link](https://example.com)
    - Second feature with ![image](image.png)
    - Third feature with &copy; entity
    
    ### Code Example
    
    ```swift
    let markdown = "# Hello"
    let doc = MarkdownParser.parse(markdown)
    print(doc)
    ```
    
    > This is a blockquote
    > with multiple lines
    > and **formatting**.
    
    ---
    
    Final paragraph with \\*escaped\\* characters.
    """
    
    static let readmeExample = """
    # syndrome
    
    A fast, lightweight Markdown parser written in pure Swift.
    
    ## Installation
    
    ### Swift Package Manager
    
    Add to your `Package.swift`:
    
    ```swift
    dependencies: [
        .package(url: "https://github.com/xamrock/syndrome.git", from: "1.0.0")
    ]
    ```
    
    ## Usage
    
    ```swift
    import syndrome
    
    let markdown = "# Hello World"
    let document = MarkdownParser.parse(markdown)
    ```
    
    ## Features
    
    - ✅ CommonMark compliant
    - ✅ Fast parsing
    - ✅ No dependencies
    - ✅ Cross-platform
    
    ## License
    
    MIT &copy; 2025 Xamrock
    """
    
    // MARK: - Edge Cases
    
    static let emptyDocument = ""
    
    static let whitespaceOnly = "   \n\t\n   "
    
    static let nestedStructures = """
    > # Heading in blockquote
    > 
    > - List in blockquote
    >   - Nested item
    > 
    > ```
    > code in blockquote
    > ```
    """
    
    static let mixedListTypes = """
    1. Ordered item
    2. Another ordered
    
    - Unordered item
    * Different marker
    + Yet another marker
    
    3. Back to ordered
    """
    
    // MARK: - CommonMark Examples
    
    static let commonMarkExample1 = """
    →foo→baz→→bim
    """
    
    static let commonMarkExample2 = """
    a→b
    """
    
    static let commonMarkATXHeadings = [
        "# foo",
        "## foo",
        "### foo",
        "#### foo",
        "##### foo",
        "###### foo"
    ]
    
    // MARK: - Performance Test Data
    
    static func largeDocument(blocks: Int = 1000) -> String {
        String(repeating: """
        # Heading \(UUID().uuidString)
        
        Paragraph with **bold** and *italic* text.
        
        - List item
        - Another item
        
        
        """, count: blocks)
    }
    
    static func deeplyNestedList(depth: Int = 10) -> String {
        var result = ""
        for level in 0..<depth {
            let indent = String(repeating: "  ", count: level)
            result += "\(indent)- Level \(level) item\n"
        }
        return result
    }
    
    // MARK: - File Loading
    
    static func loadFixture(_ name: String) throws -> String {
        // Note: Bundle.module is only available when resources are included
        // For now, return placeholder content
        throw TestDataError.fixtureNotFound(name)
    }
    
    enum TestDataError: Error {
        case fixtureNotFound(String)
    }
}