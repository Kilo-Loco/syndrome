# syndrome Package Information

## Package Overview

**Name:** syndrome  
**Version:** 1.0.0  
**Language:** Swift 5.9+  
**Platforms:** macOS, iOS, tvOS, watchOS, visionOS, Linux, Windows  
**License:** MIT  

## Features

- ✅ CommonMark-compliant Markdown parser
- ✅ NSAttributedString rendering (Apple platforms)
- ✅ Zero external dependencies
- ✅ Comprehensive test coverage (153 tests)
- ✅ High performance (O(n) parsing)
- ✅ Thread-safe implementation

## Package Contents

```
syndrome/
├── Sources/                    # Source code
│   └── syndrome/
│       ├── Models/            # Data models (BlockElement, InlineElement)
│       ├── Parser/            # Markdown parser implementation
│       └── Rendering/         # NSAttributedString renderer
├── Tests/                     # Unit tests
│   └── syndromeTests/
│       ├── ParserTests/       # Parser-specific tests
│       ├── CompatibilityTests/# Cross-platform tests
│       └── Fixtures/          # Test data
├── Examples/                  # Usage examples
├── Documentation/             # Additional documentation
├── .github/workflows/         # CI/CD automation
│   ├── ci.yml                # Continuous integration
│   └── release.yml           # Release automation
├── Package.swift             # SPM manifest
├── README.md                 # Main documentation
├── LICENSE                   # MIT license
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # Contribution guidelines
├── RELEASE.md              # Release process
└── SETUP_GITHUB.md         # GitHub setup instructions
```

## Quick Start

### Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/syndrome.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import syndrome

// Parse markdown
let document = MarkdownParser.parse("# Hello, **World**!")

// Render to NSAttributedString (Apple platforms only)
#if canImport(AppKit) || canImport(UIKit)
let attributedString = document.attributedString()
#endif
```

## Statistics

- **Source Files:** 9
- **Test Files:** 16
- **Total Tests:** 153
- **Lines of Code:** ~5000
- **Test Coverage:** High

## Supported Markdown Elements

### Block Elements
- ATX Headings (# to ######)
- Paragraphs
- Code blocks (fenced)
- Lists (ordered/unordered)
- Blockquotes
- Horizontal rules

### Inline Elements
- Bold (**text**)
- Italic (*text*)
- Inline code (`code`)
- Links ([text](url))
- Images (![alt](url))
- HTML entities (&copy;)
- Backslash escapes

## Moving the Package

To move this package to a new location:

```bash
# Copy the entire syndrome directory
cp -r syndrome /path/to/new/location/

# Navigate to the new location
cd /path/to/new/location/syndrome

# Verify the package works
swift build
swift test
```

## Publishing to GitHub

1. Create a new repository on GitHub
2. Follow instructions in `SETUP_GITHUB.md`
3. Update URLs in README.md with your GitHub username
4. Push to GitHub and create initial release

## Support

For issues or questions, please use GitHub Issues once the repository is published.

---

**Note:** This package is ready for production use and has been thoroughly tested.