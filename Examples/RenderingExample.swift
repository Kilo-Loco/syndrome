#!/usr/bin/env swift

//
//  RenderingExample.swift
//  syndrome
//
//  Example demonstrating the NSAttributedString rendering functionality
//

import Foundation
import syndrome

#if canImport(AppKit) || canImport(UIKit)

// Example markdown content
let markdown = """
# syndrome Rendering Example

This example demonstrates the **NSAttributedString** rendering capabilities of syndrome.

## Features

- ✅ **Bold text** and *italic text*
- ✅ Inline `code` snippets
- ✅ [Links](https://github.com) with proper styling
- ✅ Images: ![Alt text](image.png)

### Code Blocks

```swift
func greet(name: String) {
    print("Hello, \\(name)!")
}
```

> **Note:** This is a blockquote with **formatted** text.

---

That's all folks! Visit [syndrome](https://github.com/xamrock/syndrome) for more.
"""

// Parse and render with default options
print("=== Rendering with Default Options ===\n")
let attributedString = markdown.markdownAttributedString()
print("Rendered \(attributedString.length) characters")
print("Plain text preview:")
print(attributedString.string)
print()

// Custom rendering options
print("=== Rendering with Custom Options ===\n")
var customOptions = MarkdownRenderingOptions.default
customOptions.paragraphSpacing = 16.0
customOptions.listIndentation = 30.0

#if canImport(AppKit)
customOptions.baseFont = NSFont.systemFont(ofSize: 14)
customOptions.linkColor = NSColor.systemBlue
#elseif canImport(UIKit)
customOptions.baseFont = UIFont.systemFont(ofSize: 14)
customOptions.linkColor = UIColor.systemBlue
#endif

let document = MarkdownParser.parse(markdown)
let customAttributed = document.attributedString(options: customOptions)
print("Custom rendered \(customAttributed.length) characters")

// Analyze attributes
print("\n=== Attribute Analysis ===\n")
var foundAttributes: Set<String> = []
customAttributed.enumerateAttributes(
    in: NSRange(location: 0, length: customAttributed.length),
    options: []
) { attributes, range, _ in
    for (key, _) in attributes {
        foundAttributes.insert(key.rawValue)
    }
}

print("Found attributes:")
for attr in foundAttributes.sorted() {
    print("  - \(attr)")
}

// Find all links
print("\n=== Links Found ===\n")
customAttributed.enumerateAttribute(
    .link,
    in: NSRange(location: 0, length: customAttributed.length),
    options: []
) { value, range, _ in
    if let url = value as? String {
        let text = (customAttributed.string as NSString).substring(with: range)
        print("  [\(text)] -> \(url)")
    }
}

#else
print("NSAttributedString rendering is only available on Apple platforms")
#endif