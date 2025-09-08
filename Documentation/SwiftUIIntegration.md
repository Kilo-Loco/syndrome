# SwiftUI Integration Guide

This guide shows how to use syndrome's SwiftUI components to render Markdown content in your iOS, macOS, tvOS, or watchOS apps.

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.9+
- SwiftUI framework

## Basic Usage

### MarkdownView

The simplest way to display markdown content:

```swift
import SwiftUI
import syndrome

struct ContentView: View {
    let markdownContent = """
    # Welcome
    This is **bold** text and this is *italic* text.
    
    - List item 1
    - List item 2
    
    [Visit our website](https://example.com)
    """
    
    var body: some View {
        MarkdownView(markdownContent)
            .padding()
    }
}
```

### Text Extension

For inline markdown in Text views:

```swift
import SwiftUI
import syndrome

struct InlineExample: View {
    var body: some View {
        VStack {
            Text(markdown: "**Bold** and *italic* text")
            Text(markdown: "Visit [our site](https://example.com)")
        }
    }
}
```

## Streaming Text Support

For real-time or streaming text (like chat applications):

```swift
import SwiftUI
import syndrome

struct ChatView: View {
    @State private var message = ""
    
    var body: some View {
        StreamingMarkdownView(content: $message)
            .padding()
            .onAppear {
                // Simulate streaming text
                simulateStreaming()
            }
    }
    
    func simulateStreaming() {
        let fullMessage = "# Hello\nThis is a **streaming** message..."
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < fullMessage.count {
                let index = fullMessage.index(fullMessage.startIndex, offsetBy: currentIndex)
                message = String(fullMessage[..<fullMessage.index(after: index)])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
```

## Customization

### Using Pre-built Themes

syndrome includes several pre-built themes:

```swift
struct ThemedView: View {
    let content: String
    
    var body: some View {
        VStack(spacing: 20) {
            // GitHub-style rendering
            MarkdownView(content, options: .github)
            
            // Documentation style
            MarkdownView(content, options: .documentation)
            
            // Chat application style
            MarkdownView(content, options: .chat)
        }
    }
}
```

### Custom Rendering Options

Create your own custom styling:

```swift
import syndrome

let customOptions = MarkdownRenderingOptions(
    baseFont: .systemFont(ofSize: 16),
    textColor: .label,
    linkColor: .blue,
    codeColor: .purple,
    codeBackgroundColor: .gray.opacity(0.1),
    codeBlockBackgroundColor: .gray.opacity(0.05),
    blockquoteColor: .secondary,
    monospaceFontName: "Menlo",
    listIndentation: 32.0,
    paragraphSpacing: 16.0,
    lineSpacing: 4.0
)

struct CustomStyledView: View {
    var body: some View {
        MarkdownView(content, options: customOptions)
    }
}
```

### Environment-based Options

Apply markdown options to an entire view hierarchy:

```swift
struct AppView: View {
    var body: some View {
        NavigationView {
            ContentView()
        }
        .markdownOptions(.github)  // All MarkdownViews will use GitHub theme
    }
}
```

## Performance Considerations

### Caching Parsed Content

For static content, cache the parsed result:

```swift
struct CachedMarkdownView: View {
    let content: String
    @State private var attributedString: AttributedString?
    
    var body: some View {
        Group {
            if let attributedString = attributedString {
                Text(attributedString)
            } else {
                ProgressView()
                    .onAppear {
                        parseMarkdown()
                    }
            }
        }
    }
    
    func parseMarkdown() {
        Task {
            let document = MarkdownParser.parse(content)
            let nsAttributedString = document.attributedString(options: .default)
            if let converted = try? AttributedString(nsAttributedString, including: \.foundation) {
                await MainActor.run {
                    self.attributedString = converted
                }
            }
        }
    }
}
```

### Streaming Optimization

For frequently updating content:

```swift
struct OptimizedStreamingView: View {
    @State private var content: String
    @State private var updateTimer: Timer?
    @State private var pendingContent: String = ""
    
    var body: some View {
        StreamingMarkdownView(content: $content)
            .onChange(of: pendingContent) { newValue in
                // Debounce updates to avoid excessive re-parsing
                updateTimer?.invalidate()
                updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                    content = newValue
                }
            }
    }
}
```

## Common Use Cases

### Chat Applications

```swift
struct MessageBubble: View {
    let message: String
    let isFromUser: Bool
    
    var body: some View {
        HStack {
            if isFromUser { Spacer() }
            
            MarkdownView(message, options: .chat)
                .padding()
                .background(isFromUser ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(12)
            
            if !isFromUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
```

### Documentation Viewer

```swift
struct DocViewer: View {
    let documentation: String
    
    var body: some View {
        ScrollView {
            MarkdownView(documentation, options: .documentation)
                .padding()
        }
        .navigationTitle("Documentation")
    }
}
```

### README Display

```swift
struct ReadmeView: View {
    @State private var readmeContent = ""
    
    var body: some View {
        ScrollView {
            MarkdownView(readmeContent, options: .github)
                .padding()
        }
        .task {
            // Load README content
            if let url = Bundle.main.url(forResource: "README", withExtension: "md"),
               let content = try? String(contentsOf: url) {
                readmeContent = content
            }
        }
    }
}
```

## Troubleshooting

### Text Not Updating

If your markdown text isn't updating properly:

1. Use `StreamingMarkdownView` for frequently changing content
2. Ensure you're using `@State` or `@Binding` for dynamic content
3. Consider using `.id()` modifier to force view recreation

### Styling Not Applied

If custom styling isn't showing:

1. Verify your `MarkdownRenderingOptions` are correctly configured
2. Check that fonts are available on the target platform
3. Use `.markdownOptions()` modifier for environment-wide styling

### Performance Issues

For performance problems:

1. Cache parsed content when possible
2. Use debouncing for streaming updates
3. Consider parsing in a background task for large documents
4. Profile with Instruments to identify bottlenecks

## Best Practices

1. **Choose the right component**: Use `MarkdownView` for static content, `StreamingMarkdownView` for dynamic content
2. **Cache when possible**: Parse once and reuse for static content
3. **Use themes**: Leverage pre-built themes for consistency
4. **Test on all platforms**: Ensure your styling works across iOS, macOS, etc.
5. **Handle errors gracefully**: Always provide fallback text for parsing failures

## Example App

Here's a complete example app demonstrating various features:

```swift
import SwiftUI
import syndrome

@main
struct MarkdownDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .markdownOptions(.default)
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StaticContentView()
                .tabItem { Label("Static", systemImage: "doc.text") }
                .tag(0)
            
            StreamingContentView()
                .tabItem { Label("Streaming", systemImage: "text.bubble") }
                .tag(1)
            
            ThemeShowcase()
                .tabItem { Label("Themes", systemImage: "paintbrush") }
                .tag(2)
        }
    }
}

struct StaticContentView: View {
    let markdown = """
    # syndrome Demo
    
    This demonstrates **various** markdown features:
    
    - Lists with **bold** items
    - Links to [websites](https://example.com)
    - Inline `code` snippets
    
    ```swift
    let example = "Code blocks too!"
    ```
    """
    
    var body: some View {
        ScrollView {
            MarkdownView(markdown)
                .padding()
        }
        .navigationTitle("Static Content")
    }
}

struct StreamingContentView: View {
    @State private var content = ""
    
    var body: some View {
        VStack {
            StreamingMarkdownView(content: $content)
                .padding()
            
            Spacer()
            
            Button("Simulate Streaming") {
                simulateStreaming()
            }
            .padding()
        }
    }
    
    func simulateStreaming() {
        content = ""
        let message = "# Streaming Demo\n\nThis text appears **gradually**..."
        var index = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if index < message.count {
                let charIndex = message.index(message.startIndex, offsetBy: index)
                content.append(message[charIndex])
                index += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

struct ThemeShowcase: View {
    let content = """
    # Theme Showcase
    
    This is a **sample** document with:
    - Various elements
    - `inline code`
    - [Links](https://example.com)
    
    > A blockquote for emphasis
    """
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ThemeSection(title: "Default", content: content, options: .default)
                ThemeSection(title: "GitHub", content: content, options: .github)
                ThemeSection(title: "Documentation", content: content, options: .documentation)
                ThemeSection(title: "Chat", content: content, options: .chat)
            }
            .padding()
        }
    }
}

struct ThemeSection: View {
    let title: String
    let content: String
    let options: MarkdownRenderingOptions
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            MarkdownView(content, options: options)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
        }
    }
}
```

## Next Steps

- Explore the [API Documentation](API.md) for detailed method signatures
- Check out [Performance Tips](Performance.md) for optimization strategies
- See [Examples](Examples/) for more use cases
- Report issues or request features on [GitHub](https://github.com/yourusername/syndrome)