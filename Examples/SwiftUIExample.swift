//
//  SwiftUIExample.swift
//  syndrome
//
//  Example SwiftUI app demonstrating syndrome's SwiftUI features
//

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI
import syndrome

// MARK: - Main App

@main
@available(iOS 15.0, macOS 12.0, *)
struct SyndromeExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .markdownOptions(.default)  // Set app-wide default
        }
    }
}

// MARK: - Main Content View

@available(iOS 15.0, macOS 12.0, *)
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BasicExampleView()
                .tabItem {
                    Label("Basic", systemImage: "doc.text")
                }
                .tag(0)
            
            StreamingExampleView()
                .tabItem {
                    Label("Streaming", systemImage: "message")
                }
                .tag(1)
            
            ThemeShowcaseView()
                .tabItem {
                    Label("Themes", systemImage: "paintbrush")
                }
                .tag(2)
            
            ChatExampleView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(3)
            
            DocumentationView()
                .tabItem {
                    Label("Docs", systemImage: "book")
                }
                .tag(4)
        }
    }
}

// MARK: - Basic Usage Example

@available(iOS 15.0, macOS 12.0, *)
struct BasicExampleView: View {
    let markdownContent = """
    # syndrome SwiftUI Demo
    
    This demonstrates **various** markdown features in SwiftUI:
    
    ## Features
    
    - ✅ **Bold** and *italic* text
    - ✅ `Inline code` snippets
    - ✅ [Links](https://github.com/syndrome) to external sites
    - ✅ Images: ![Alt text](https://via.placeholder.com/150)
    
    ### Code Blocks
    
    ```swift
    let parser = MarkdownParser()
    let document = parser.parse(markdown)
    print("Parsing complete!")
    ```
    
    > **Note:** This is a blockquote demonstrating
    > how syndrome handles quoted text with
    > multiple lines.
    
    ---
    
    That's all for the basic demo!
    """
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Standard MarkdownView
                    MarkdownView(markdownContent)
                        .padding()
                    
                    Divider()
                    
                    // Inline Text with markdown
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Inline Examples:")
                            .font(.headline)
                        
                        Text(markdown: "This is **bold** text")
                        Text(markdown: "This is *italic* text")
                        Text(markdown: "This has `inline code`")
                        Text(markdown: "This is a [link](https://example.com)")
                    }
                    .padding()
                }
            }
            .navigationTitle("Basic Usage")
        }
    }
}

// MARK: - Streaming Example

@available(iOS 15.0, macOS 12.0, *)
struct StreamingExampleView: View {
    @State private var streamingContent = ""
    @State private var isStreaming = false
    
    let fullMessage = """
    # Streaming Demo
    
    This simulates a **streaming** response, like from an AI assistant.
    
    ## Key Points
    
    - Text appears gradually
    - Markdown is parsed in real-time
    - UI updates smoothly
    
    ```swift
    func streamResponse() {
        // Simulating API response
        for char in response {
            content.append(char)
            await Task.sleep(50_000_000)
        }
    }
    ```
    
    > The streaming view handles partial markdown gracefully,
    > even when tags are incomplete.
    
    **Thank you** for watching the demo!
    """
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    StreamingMarkdownView(content: $streamingContent, options: .chat)
                        .padding()
                }
                
                Spacer()
                
                HStack {
                    Button(action: startStreaming) {
                        Label("Start Streaming", systemImage: "play.fill")
                    }
                    .disabled(isStreaming)
                    
                    Button(action: reset) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .disabled(isStreaming)
                }
                .padding()
            }
            .navigationTitle("Streaming Text")
        }
    }
    
    func startStreaming() {
        isStreaming = true
        streamingContent = ""
        
        Task {
            for (index, char) in fullMessage.enumerated() {
                streamingContent.append(char)
                
                // Vary the speed for effect
                let delay = char == " " ? 20_000_000 : 30_000_000
                try? await Task.sleep(nanoseconds: UInt64(delay))
                
                if index == fullMessage.count - 1 {
                    await MainActor.run {
                        isStreaming = false
                    }
                }
            }
        }
    }
    
    func reset() {
        streamingContent = ""
    }
}

// MARK: - Theme Showcase

@available(iOS 15.0, macOS 12.0, *)
struct ThemeShowcaseView: View {
    let sampleContent = """
    # Theme Showcase
    
    This is **sample** content to demonstrate different themes.
    
    - First item with `code`
    - Second item with [link](https://example.com)
    - Third item with *emphasis*
    
    ```swift
    let theme = MarkdownRenderingOptions.github
    ```
    
    > A blockquote to show quote styling
    """
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    ThemeSection(
                        title: "Default Theme",
                        content: sampleContent,
                        options: .default
                    )
                    
                    ThemeSection(
                        title: "GitHub Theme",
                        content: sampleContent,
                        options: .github
                    )
                    
                    ThemeSection(
                        title: "Documentation Theme",
                        content: sampleContent,
                        options: .documentation
                    )
                    
                    ThemeSection(
                        title: "Chat Theme",
                        content: sampleContent,
                        options: .chat
                    )
                }
                .padding()
            }
            .navigationTitle("Themes")
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct ThemeSection: View {
    let title: String
    let content: String
    let options: MarkdownRenderingOptions
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            MarkdownView(content, options: options)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
        }
    }
}

// MARK: - Chat Example

@available(iOS 15.0, macOS 12.0, *)
struct ChatExampleView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            content: "# Welcome!\n\nI'm your **AI assistant**. I can help with:\n\n- Writing code\n- Answering questions\n- Explaining concepts",
            isUser: false
        )
    ]
    @State private var newMessage = ""
    @State private var isTyping = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if isTyping {
                                TypingIndicator()
                            }
                        }
                        .padding()
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Chat Demo")
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        // Add user message
        messages.append(ChatMessage(content: newMessage, isUser: true))
        let userMessage = newMessage
        newMessage = ""
        
        // Simulate AI response
        isTyping = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            
            await MainActor.run {
                isTyping = false
                
                let response = generateAIResponse(for: userMessage)
                messages.append(ChatMessage(content: response, isUser: false))
            }
        }
    }
    
    func generateAIResponse(for message: String) -> String {
        // Simulate different responses
        if message.lowercased().contains("code") {
            return """
            Here's an example of **Swift** code:
            
            ```swift
            struct ContentView: View {
                var body: some View {
                    Text("Hello, World!")
                }
            }
            ```
            
            This creates a simple SwiftUI view.
            """
        } else if message.lowercased().contains("list") {
            return """
            Here's a formatted list:
            
            1. **First** item
            2. *Second* item with emphasis
            3. `Third` item with code
            
            You can also use unordered lists:
            - Item A
            - Item B
            """
        } else {
            return """
            I understand you said: "*\(message)*"
            
            Here's a **formatted** response with:
            - Some bullet points
            - `Inline code`
            - [A link](https://example.com)
            
            > And even a blockquote for emphasis!
            """
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

@available(iOS 15.0, macOS 12.0, *)
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            MarkdownView(message.content, options: .chat)
                .padding()
                .background(
                    message.isUser
                        ? Color.blue.opacity(0.8)
                        : Color.gray.opacity(0.2)
                )
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(15)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount)
                        .opacity(animationAmount)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .frame(maxWidth: 280, alignment: .leading)
            
            Spacer()
        }
        .onAppear {
            animationAmount = 1.0
        }
    }
}

// MARK: - Documentation Viewer

@available(iOS 15.0, macOS 12.0, *)
struct DocumentationView: View {
    let documentation = """
    # syndrome Documentation
    
    ## Installation
    
    Add syndrome to your `Package.swift`:
    
    ```swift
    dependencies: [
        .package(url: "https://github.com/syndrome", from: "2.0.0")
    ]
    ```
    
    ## Basic Usage
    
    ### SwiftUI
    
    The simplest way to display markdown:
    
    ```swift
    MarkdownView("# Hello World")
    ```
    
    ### Custom Options
    
    Apply custom styling:
    
    ```swift
    MarkdownView(content, options: .github)
    ```
    
    ## API Reference
    
    ### MarkdownView
    
    A SwiftUI view that renders markdown content.
    
    **Parameters:**
    - `content`: The markdown string to render
    - `options`: Rendering options (optional)
    
    ### StreamingMarkdownView
    
    Optimized for frequently updating content.
    
    **Parameters:**
    - `content`: Binding to markdown string
    - `options`: Rendering options (optional)
    
    ## Themes
    
    | Theme | Use Case |
    |-------|----------|
    | `.default` | General purpose |
    | `.github` | README files |
    | `.documentation` | Technical docs |
    | `.chat` | Messaging apps |
    
    ## Performance Tips
    
    1. **Cache parsed content** when possible
    2. **Use StreamingMarkdownView** for dynamic content
    3. **Apply themes** at the app level
    
    ---
    
    For more information, visit our [GitHub repository](https://github.com/syndrome).
    """
    
    var body: some View {
        NavigationView {
            ScrollView {
                MarkdownView(documentation, options: .documentation)
                    .padding()
            }
            .navigationTitle("Documentation")
        }
    }
}

#endif