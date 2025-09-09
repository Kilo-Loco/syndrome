# syndrome

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20Linux%20|%20Windows-lightgray.svg)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A high-performance, pure Swift Markdown parser with CommonMark compatibility and useful extensions.

## 🎉 What's New in v2.1

### Enhanced Typography & Styling (xamrock-client improvements)
- **Advanced Typography Control**: 
  - `lineHeightMultiple` for precise line height control
  - `paragraphSpacingBefore` for paragraph spacing customization
- **Header Customization**: 
  - `headerFontWeights` array for per-level font weights (H1-H6)
  - `headerFontScales` array for custom header size multipliers
- **List Formatting**: 
  - `listItemSpacing` for controlling space between list items
  - `nestedListIndentation` for nested list indentation control
- **Code Block Styling**: 
  - `codeBlockPadding` for internal padding
  - `codeBlockBorderRadius` and `codeBlockBorderColor` for visual polish
- **Blockquote Enhancements**: 
  - `blockquoteLeftBorderWidth` and `blockquoteLeftBorderColor`
  - `blockquoteBackgroundColor` and `blockquotePadding`
- **Link Styling**: 
  - `linkUnderlineStyle` (including option to remove underlines)
  - `linkFontWeight` for custom link emphasis

### v2.0 Features
- **Native SwiftUI Support**: New `MarkdownView` and `StreamingMarkdownView` components
- **Text Extension**: Use `Text(markdown:)` for inline markdown rendering
- **Pre-built Themes**: GitHub, Documentation, and Chat themes with enhanced defaults
- **Improved Spacing**: Better default paragraph and line spacing values
- **Full Emoji Support**: Complete Unicode emoji rendering (🎉 📊 💻 ✅)
- **Streaming Optimization**: Efficient handling of real-time text updates

See the [SwiftUI Integration Guide](Documentation/SwiftUIIntegration.md) for details.

## Features

✅ **CommonMark Compatible** - Follows the CommonMark specification  
✅ **Pure Swift** - No external dependencies, works on all Swift platforms  
✅ **Fast** - Optimized for performance with linear time complexity  
✅ **Safe** - Memory-safe, thread-safe, and thoroughly tested  
✅ **SwiftUI Native** - First-class SwiftUI support with MarkdownView  
✅ **Streaming Support** - Optimized for real-time text updates  
✅ **Rich Rendering** - Built-in NSAttributedString with themes  
✅ **Well-Documented** - Comprehensive API documentation with examples  

### Supported Markdown Elements

- ✅ Headings (ATX-style: `# H1`, `## H2`, etc.)
- ✅ Paragraphs with inline formatting
- ✅ Bold (`**bold**`, `__bold__`)
- ✅ Italic (`*italic*`, `_italic_`)
- ✅ Inline code (`` `code` ``)
- ✅ Code blocks (fenced with ``` or ~~~)
- ✅ Unordered lists (`-`, `*`, `+`)
- ✅ Ordered lists (`1.`, `1)`)
- ✅ Blockquotes (`>`)
- ✅ Horizontal rules (`---`, `***`, `___`)
- ✅ Links (`[text](url)`)
- ✅ Images (`![alt](url)`)
- ✅ HTML entities (`&copy;`, `&#169;`, `&#x00A9;`)
- ✅ Backslash escapes (`\*`, `\_`, etc.)
- ✅ Tab expansion

### Coming Soon

- ⏳ Tables
- ⏳ Task lists
- ⏳ Footnotes
- ⏳ Definition lists
- ⏳ Setext headings
- ⏳ Indented code blocks

## Installation

### Swift Package Manager

Add syndrome to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/syndrome.git", from: "1.0.0")
]
```

Then add it to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["syndrome"]
)
```

### Xcode

1. File → Add Package Dependencies
2. Enter: `https://github.com/yourusername/syndrome.git`
3. Select version requirements
4. Add to your target

> **Note:** Replace `yourusername` with your actual GitHub username or organization name.

## Quick Start

### SwiftUI (New!)

```swift
import SwiftUI
import syndrome

struct ContentView: View {
    var body: some View {
        // Simple markdown rendering
        MarkdownView("# Hello\nThis is **bold** text")
        
        // Streaming support for chat apps
        StreamingMarkdownView(content: $messageContent)
        
        // Inline markdown in Text views
        Text(markdown: "**Bold** and *italic* text")
    }
}
```

### UIKit/AppKit

```swift
import syndrome

let markdown = """
    # Welcome to syndrome
    
    This is a **powerful** and *flexible* Markdown parser.
    
    - Fast parsing
    - CommonMark compatible
    - Cross-platform support
    """

// Parse the markdown
let document = MarkdownParser.parse(markdown)

// Render to NSAttributedString with themes
#if canImport(UIKit) || canImport(AppKit)
let attributedString = document.attributedString(options: .github)
// Use in UITextView, NSTextView, UILabel, etc.
#endif

// Or access the parsed structure directly
for block in document.blocks {
    switch block {
    case .heading(let level, let content):
        print("H\(level): \(content.map { $0.plainText }.joined())")
    case .paragraph(let content):
        print("Paragraph: \(content.map { $0.plainText }.joined())")
    case .list(let items, let type):
        print("List (\(type)) with \(items.count) items")
    default:
        break
    }
}
```

## Usage Examples

### Basic Parsing

```swift
let document = MarkdownParser.parse("# Hello, World!")
// Returns a MarkdownDocument with one heading block
```

### Working with Headings

```swift
let markdown = """
    # Title
    ## Subtitle
    ### Section
    """

let document = MarkdownParser.parse(markdown)

let headings = document.blocks.compactMap { block -> (Int, String)? in
    if case .heading(let level, let content) = block {
        let text = content.map { $0.plainText }.joined()
        return (level, text)
    }
    return nil
}

// headings: [(1, "Title"), (2, "Subtitle"), (3, "Section")]
```

### Processing Lists

```swift
let markdown = """
    - Item 1
    - Item 2
      - Nested item
    - Item 3
    """

let document = MarkdownParser.parse(markdown)

for block in document.blocks {
    if case .list(let items, let type) = block {
        print("Found \(type) list with \(items.count) items")
        for item in items {
            print("  - \(item.content.map { $0.plainText }.joined())")
        }
    }
}
```

### Extracting Links

```swift
let markdown = "Check out [our website](https://example.com) and [documentation](https://docs.example.com)"
let document = MarkdownParser.parse(markdown)

// Extract all links from the document
var links: [(text: String, url: String)] = []

func extractLinks(from elements: [InlineElement]) {
    for element in elements {
        switch element {
        case .link(let content, let url, _):
            let text = content.map { $0.plainText }.joined()
            links.append((text, url))
        case .strong(let nested), .emphasis(let nested):
            extractLinks(from: nested)
        default:
            break
        }
    }
}

for block in document.blocks {
    if case .paragraph(let content) = block {
        extractLinks(from: content)
    }
}

// links: [("our website", "https://example.com"), ("documentation", "https://docs.example.com")]
```

### HTML Entities

```swift
let markdown = "&copy; 2024 &mdash; All rights reserved &nbsp;&nbsp; &hearts;"
let document = MarkdownParser.parse(markdown)

if case .paragraph(let content) = document.blocks.first {
    let text = content.map { $0.plainText }.joined()
    print(text) // © 2024 — All rights reserved     ♥
}
```

### Escaping Special Characters

```swift
let markdown = "Use \\* for multiplication and \\_ for underscore"
let document = MarkdownParser.parse(markdown)

if case .paragraph(let content) = document.blocks.first {
    let text = content.map { $0.plainText }.joined()
    print(text) // Use * for multiplication and _ for underscore
}
```

### Working with Code Blocks

```swift
let markdown = """
    ```swift
    func hello() {
        print("Hello, World!")
    }
    ```
    """

let document = MarkdownParser.parse(markdown)

for block in document.blocks {
    if case .codeBlock(let code, let language) = block {
        print("Language: \(language ?? "none")")
        print("Code: \(code)")
    }
}
```

### Rendering to NSAttributedString (iOS/macOS)

```swift
import syndrome

// Simple rendering with default options
let markdown = "# Title\n\nThis is **bold** and *italic* text with emoji 🎉"
let attributedString = markdown.markdownAttributedString()

// Rendering with pre-built themes
let githubStyled = document.attributedString(options: .github)
let docStyled = document.attributedString(options: .documentation)
let chatStyled = document.attributedString(options: .chat)

// Advanced customization with new v2.1 features
var options = MarkdownRenderingOptions(
    baseFont: .systemFont(ofSize: 16),
    textColor: .label,
    linkColor: .systemBlue,
    codeColor: .label,
    codeBackgroundColor: .secondarySystemBackground,
    codeBlockBackgroundColor: .tertiarySystemBackground,
    blockquoteColor: .secondaryLabel,
    // Typography control
    lineHeightMultiple: 1.4,
    paragraphSpacing: 16.0,
    paragraphSpacingBefore: 8.0,
    // Custom header styling
    headerFontWeights: [.heavy, .bold, .semibold, .medium, .regular, .light],
    headerFontScales: [2.5, 2.0, 1.5, 1.3, 1.1, 1.0],
    // List formatting
    listItemSpacing: 6.0,
    nestedListIndentation: 32.0,
    // Code block styling
    codeBlockPadding: 12.0,
    codeBlockBorderRadius: 8.0,
    // Blockquote styling
    blockquoteLeftBorderWidth: 4.0,
    blockquoteLeftBorderColor: .systemBlue,
    blockquoteBackgroundColor: .quaternarySystemFill,
    blockquotePadding: 12.0,
    // Link styling
    linkUnderlineStyle: nil,  // No underline
    linkFontWeight: .medium
)

let customAttributed = document.attributedString(options: options)

// Use in UI components
#if canImport(UIKit)
textView.attributedText = attributedString
#elseif canImport(AppKit)
textView.textStorage?.setAttributedString(attributedString)
#endif
```

## Performance

syndrome is designed for high performance:

- **Linear time complexity** - O(n) parsing
- **Minimal allocations** - Efficient memory usage
- **Thread-safe** - Safe for concurrent use
- **Optimized for common cases** - Fast path for typical Markdown

Benchmarks on MacBook Pro M1:
- Small document (1KB): ~0.1ms
- Medium document (10KB): ~1ms  
- Large document (100KB): ~10ms

## API Documentation

### Main Types

- `MarkdownParser` - The main parser class with a static `parse(_:)` method
- `MarkdownDocument` - The root document containing parsed blocks
- `BlockElement` - Enum representing block-level elements (headings, paragraphs, lists, etc.)
- `InlineElement` - Enum representing inline elements (text, emphasis, links, etc.)
- `MarkdownRenderer` - Renders parsed documents to NSAttributedString (Apple platforms only)
- `MarkdownRenderingOptions` - Configuration for customizing the rendered output

### Parser Options

The parser currently uses sensible defaults. Future versions will support configuration options for:
- Tab width adjustment
- Strict CommonMark mode
- Extension enabling/disabling

## Requirements

- Swift 5.9+
- macOS 13.0+ / iOS 16.0+ / watchOS 9.0+ / tvOS 16.0+ / visionOS 1.0+ / Linux / Windows

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development

```bash
# Clone the repository
git clone https://github.com/xamrock/syndrome.git
cd syndrome

# Build the package
swift build

# Run tests
swift test

# Generate documentation
swift package generate-documentation
```

### Testing

The package includes comprehensive tests:

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter BlockParsingTests

# Run with coverage
swift test --enable-code-coverage
```

## Architecture

syndrome uses a clean, modular architecture:

- **Parser** - Converts Markdown text to document model
- **Models** - Strongly-typed representation of Markdown elements
- **Extensions** - Additional functionality and utilities

The parser follows a two-phase approach:
1. **Block parsing** - Identifies block-level structures
2. **Inline parsing** - Processes inline elements within blocks

## License

syndrome is available under the MIT license. See [LICENSE](LICENSE) for details.

## Acknowledgments

- [CommonMark](https://commonmark.org) for the specification
- The Swift community for feedback and contributions

## Support

- 🐛 [Issue Tracker](https://github.com/xamrock/syndrome/issues)
- 💬 [Discussions](https://github.com/xamrock/syndrome/discussions)

---

Made with ❤️ by the Xamrock team