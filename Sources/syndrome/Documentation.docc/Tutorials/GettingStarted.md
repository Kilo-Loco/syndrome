# Getting Started with syndrome

Learn how to integrate and use syndrome in your Swift projects.

## Installation

### Swift Package Manager

Add syndrome to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/xamrock/syndrome.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version requirements

## Basic Usage

### Parsing Markdown

The simplest way to parse Markdown is using the static `parse` method:

```swift
import syndrome

let markdown = """
# Welcome to syndrome

This is a **bold** statement with *emphasis*.

- Feature 1
- Feature 2
- Feature 3
"""

let document = MarkdownParser.parse(markdown)
```

### Accessing Document Structure

Once parsed, you can traverse the document structure:

```swift
for block in document.blocks {
    switch block {
    case .heading(let level, let content):
        print("Found heading level \(level)")
        
    case .paragraph(let content):
        print("Found paragraph with \(content.count) inline elements")
        
    case .list(let items, let type):
        print("Found list with \(items.count) items")
        
    default:
        break
    }
}
```

### Working with Inline Elements

Inline elements provide formatting within blocks:

```swift
func extractText(from inlineElements: [InlineElement]) -> String {
    var text = ""
    
    for element in inlineElements {
        switch element {
        case .text(let string):
            text += string
            
        case .emphasis(let content), .strongEmphasis(let content):
            text += extractText(from: content)
            
        case .code(let code):
            text += code
            
        case .softBreak:
            text += " "
            
        case .hardBreak:
            text += "\n"
            
        default:
            break
        }
    }
    
    return text
}
```

## Common Patterns

### Finding All Headings

```swift
extension MarkdownDocument {
    var headings: [(level: Int, text: String)] {
        blocks.compactMap { block in
            if case .heading(let level, let content) = block {
                let text = extractText(from: content)
                return (level: level, text: text)
            }
            return nil
        }
    }
}

// Usage
let headings = document.headings
for heading in headings {
    let indent = String(repeating: "  ", count: heading.level - 1)
    print("\(indent)- \(heading.text)")
}
```

### Extracting All Links

```swift
func extractLinks(from document: MarkdownDocument) -> [(text: String, url: String)] {
    var links: [(String, String)] = []
    
    for block in document.blocks {
        links.append(contentsOf: extractLinksFromBlock(block))
    }
    
    return links
}

func extractLinksFromBlock(_ block: BlockElement) -> [(String, String)] {
    // Implementation to extract links from various block types
    // ...
}
```

## Next Steps

- Learn about advanced parsing features in <doc:ParsingBasics>
- Explore performance optimization in <doc:Performance>
- Understand the architecture in <doc:Architecture>