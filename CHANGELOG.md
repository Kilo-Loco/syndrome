# Changelog

All notable changes to syndrome will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- NSAttributedString rendering support for Apple platforms (iOS, macOS, tvOS, watchOS)
- `MarkdownRenderer` class for converting parsed documents to attributed strings
- `MarkdownRenderingOptions` for customizing fonts, colors, and spacing
- Convenience methods on `MarkdownDocument` and `String` for easy rendering
- Platform-specific font and color handling for AppKit and UIKit
- Comprehensive documentation and tutorials
- Performance benchmarks
- Cross-platform compatibility tests

### Changed
- Improved inline parsing performance
- Enhanced error messages for better debugging

### Fixed
- Tab handling in nested lists
- Entity reference parsing in edge cases

## [1.0.0] - 2024-08-30

### Added
- Initial release of syndrome
- Complete CommonMark parser implementation (partial compliance)
- Support for ATX headings (`#`, `##`, etc.)
- Support for paragraphs with inline formatting
- Bold emphasis (`**text**`, `__text__`)
- Italic emphasis (`*text*`, `_text_`)
- Inline code (`` `code` ``)
- Fenced code blocks with language hints
- Unordered lists (`-`, `*`, `+`)
- Ordered lists (`1.`, `1)`)
- Nested list support
- Blockquotes with nesting
- Horizontal rules (`---`, `***`, `___`)
- Links with titles (`[text](url "title")`)
- Images with alt text (`![alt](url)`)
- HTML entity support (named and numeric)
- Backslash escape sequences
- Tab expansion (4-space boundaries)
- Line breaks (two spaces at end of line)
- Comprehensive test suite (145+ tests)
- Full API documentation
- Multi-platform support (macOS, iOS, tvOS, watchOS, visionOS, Linux, Windows)

### Performance
- O(n) linear time complexity parsing
- Optimized for documents under 1MB
- Thread-safe implementation
- Minimal memory allocations

### Known Limitations
- Setext headings not yet supported
- Indented code blocks not yet supported
- Tables not yet supported
- Task lists not yet supported
- Footnotes not yet supported
- Definition lists not yet supported

## [0.9.0-beta] - 2024-08-15

### Added
- Beta release for testing
- Core parser functionality
- Basic inline and block elements
- Initial test suite

### Changed
- Refactored parser architecture
- Improved type safety with enums

### Fixed
- Memory leaks in recursive parsing
- Incorrect list indentation handling

## [0.1.0-alpha] - 2024-08-01

### Added
- Initial alpha release
- Basic Markdown parsing
- Proof of concept implementation

---

## Version History Notes

### Versioning Strategy

We follow Semantic Versioning (SemVer):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions  
- **PATCH** version for backwards-compatible bug fixes

### Migration Guides

#### Migrating from 0.x to 1.0

The 1.0 release includes breaking changes from the beta:

1. **API Changes**:
   - `Parser.parseMarkdown()` → `MarkdownParser.parse()`
   - Return type changed from `[Element]` to `MarkdownDocument`

2. **Model Changes**:
   - Separate `BlockElement` and `InlineElement` enums
   - New `MarkdownDocument` root type

3. **Import Changes**:
   ```swift
   // Before
   import XamrockParser
   
   // After
   import syndrome
   ```

### Deprecation Policy

- Deprecated features will be marked with `@available` attributes
- Deprecations will be maintained for at least one minor version
- Clear migration paths will be provided in documentation

### Support Policy

- Latest major version: Full support
- Previous major version: Security updates for 6 months
- Older versions: Community support only

---

For more details on changes, see the [GitHub Releases](https://github.com/xamrock/syndrome/releases) page.