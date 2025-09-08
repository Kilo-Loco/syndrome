# Contributing to syndrome

Thank you for your interest in contributing to syndrome! We welcome contributions from the community and are excited to work with you.

## Code of Conduct

Please note that this project adheres to a Code of Conduct. By participating, you are expected to uphold this code:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Accept feedback gracefully
- Prioritize the community's best interests

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

1. **Clear title and description** - Explain the problem and expected behavior
2. **Reproduction steps** - List the exact steps to reproduce the issue
3. **Environment details** - Swift version, platform, syndrome version
4. **Code samples** - Minimal code that demonstrates the issue
5. **Error messages** - Complete error messages or stack traces

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

1. **Use case** - Explain why this enhancement would be useful
2. **Proposed solution** - Describe your ideal solution
3. **Alternatives** - List any alternative solutions you've considered
4. **Additional context** - Add any other relevant information

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding standards** (see below)
3. **Add tests** for any new functionality
4. **Update documentation** as needed
5. **Ensure all tests pass** before submitting
6. **Write a clear PR description** explaining your changes

## Development Process

### Setting Up Your Environment

```bash
# Clone your fork
git clone https://github.com/your-username/syndrome.git
cd syndrome

# Add upstream remote
git remote add upstream https://github.com/xamrock/syndrome.git

# Create a feature branch
git checkout -b feature/your-feature-name
```

### Building and Testing

```bash
# Build the package
swift build

# Run all tests
swift test

# Run specific tests
swift test --filter YourTestName

# Build documentation
swift package generate-documentation
```

### Coding Standards

#### Swift Style Guide

- Use Swift's official API Design Guidelines
- Indent with 4 spaces (no tabs in code)
- Maximum line length of 120 characters
- Use descriptive variable and function names
- Document all public APIs with doc comments

#### Code Organization

```swift
// MARK: - Properties
// Group related properties together

// MARK: - Initialization
// Initializers

// MARK: - Public Methods
// Public API

// MARK: - Private Methods
// Internal implementation
```

#### Documentation

```swift
/// Parses a Markdown string into a document structure.
///
/// This method processes the input text through two phases:
/// 1. Block-level parsing to identify structure
/// 2. Inline parsing within each block
///
/// - Parameter markdown: The Markdown text to parse
/// - Returns: A `MarkdownDocument` containing the parsed elements
/// - Complexity: O(n) where n is the length of the input
public static func parse(_ markdown: String) -> MarkdownDocument {
    // Implementation
}
```

### Testing Guidelines

#### Test Structure

```swift
@Suite("Feature Name Tests")
struct FeatureTests {
    @Test("Should handle basic case")
    func testBasicCase() {
        let input = "test input"
        let expected = ExpectedOutput()
        let result = MarkdownParser.parse(input)
        #expect(result == expected)
    }
    
    @Test("Should handle edge case")
    func testEdgeCase() {
        // Test implementation
    }
}
```

#### Test Coverage

- Aim for >90% code coverage
- Test both happy paths and edge cases
- Include tests for error conditions
- Add performance tests for critical paths

### Commit Messages

Follow the conventional commits specification:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions or fixes
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

Examples:
```
feat(parser): add support for task lists
fix(inline): correct emphasis parsing with underscores
docs(readme): update installation instructions
test(blocks): add tests for nested blockquotes
```

## Project Structure

```
syndrome/
├── Sources/
│   └── syndrome/
│       ├── Models/           # Data models
│       ├── Parser/           # Parser implementation
│       ├── Extensions/       # Utility extensions
│       └── Documentation/   # DocC catalog
├── Tests/
│   └── syndromeTests/
│       ├── ParserTests/     # Parser unit tests
│       ├── CompatibilityTests/ # CommonMark tests
│       └── Fixtures/        # Test data
└── Supporting Files/        # README, LICENSE, etc.
```

## Release Process

1. **Version Bump** - Update version in appropriate files
2. **Changelog** - Update CHANGELOG.md with release notes
3. **Testing** - Ensure all tests pass on all platforms
4. **Documentation** - Update documentation as needed
5. **Tag** - Create a git tag following semantic versioning
6. **Release** - Create GitHub release with notes

## Getting Help

- **Documentation**: Check the README and API documentation
- **Issues**: Search existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions
- **Swift Forums**: Ask in the Swift community forums

## Recognition

Contributors will be recognized in:
- The project's contributor list
- Release notes for significant contributions
- Special thanks in documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue or start a discussion if you have questions about contributing!

---

Thank you for helping make syndrome better! 🎉