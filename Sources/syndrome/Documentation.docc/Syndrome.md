# ``syndrome``

A fast, lightweight Markdown parser written in pure Swift with no external dependencies.

## Overview

syndrome provides a robust Markdown parsing solution for Swift applications. It converts Markdown-formatted text into a structured document model that can be easily traversed and rendered.

### Key Features

- **Pure Swift**: No external dependencies, only Foundation
- **Cross-platform**: Works on macOS, iOS, watchOS, tvOS, visionOS, Linux, and Windows
- **CommonMark compliant**: Follows CommonMark specifications with useful extensions
- **Thread-safe**: Stateless parser can be used concurrently
- **Performant**: O(n) parsing with minimal memory overhead

## Topics

### Getting Started

- ``MarkdownParser``
- ``MarkdownDocument``
- <doc:GettingStarted>

### Document Structure

- ``BlockElement``
- ``InlineElement``
- ``ListType``
- ``ListItem``

### Advanced Usage

- ``MarkdownElement``
- ``MarkdownElementType``
- <doc:ParsingBasics>
- <doc:AdvancedUsage>

### Architecture

- <doc:Architecture>
- <doc:Performance>
- <doc:Extending>