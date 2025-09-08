//
//  ChatAppExample.swift
//  syndrome
//
//  Example showing how to use syndrome in a chat application
//

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI
import syndrome

@available(iOS 15.0, macOS 12.0, *)
struct ChatAppExample: View {
    @State private var messages: [Message] = []
    @State private var currentResponse = ""
    @State private var isReceiving = false
    
    var body: some View {
        VStack {
            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            MessageView(message: message)
                                .id(message.id)
                        }
                        
                        // Show streaming message if receiving
                        if isReceiving && !currentResponse.isEmpty {
                            StreamingMessageView(content: $currentResponse)
                                .id("streaming")
                        }
                    }
                    .padding()
                    .onChange(of: currentResponse) { _ in
                        withAnimation {
                            proxy.scrollTo("streaming", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            HStack {
                Button("Send Test Message") {
                    sendTestMessage()
                }
                .disabled(isReceiving)
                
                Button("Send Code Example") {
                    sendCodeExample()
                }
                .disabled(isReceiving)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func sendTestMessage() {
        // Add user message
        let userMessage = Message(
            content: "Can you explain **markdown** formatting?",
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Simulate streaming response
        isReceiving = true
        currentResponse = ""
        
        let response = """
        # Markdown Formatting Guide
        
        Markdown is a **lightweight** markup language that allows you to format text using simple syntax:
        
        ## Text Formatting
        - **Bold**: Use `**text**` or `__text__`
        - *Italic*: Use `*text*` or `_text_`
        - `Code`: Use backticks `` `code` ``
        
        ## Lists
        ### Unordered
        - Item 1
        - Item 2
          - Nested item
        
        ### Ordered
        1. First item
        2. Second item
        
        ## Links and Images
        - Links: `[text](url)`
        - Images: `![alt text](url)`
        
        > **Pro tip:** You can combine formatting like ***bold italic*** text!
        """
        
        // Simulate streaming
        Task {
            for character in response {
                currentResponse.append(character)
                try? await Task.sleep(nanoseconds: 10_000_000) // 10ms per character
            }
            
            await MainActor.run {
                messages.append(Message(
                    content: currentResponse,
                    isUser: false,
                    timestamp: Date()
                ))
                currentResponse = ""
                isReceiving = false
            }
        }
    }
    
    func sendCodeExample() {
        // Add user message
        let userMessage = Message(
            content: "Show me a Swift code example",
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Simulate streaming response
        isReceiving = true
        currentResponse = ""
        
        let response = """
        Here's a **SwiftUI** example using syndrome:
        
        ```swift
        import SwiftUI
        import syndrome
        
        struct ContentView: View {
            let markdown = \"\"\"
                # Welcome
                This is **bold** and *italic* text.
                \"\"\"
            
            var body: some View {
                // Using MarkdownView
                MarkdownView(markdown, options: .chat)
                    .padding()
            }
        }
        ```
        
        This creates a view that renders markdown with the chat theme, perfect for messaging applications!
        
        You can also use `StreamingMarkdownView` for real-time updates:
        
        ```swift
        @State private var content = ""
        
        StreamingMarkdownView(content: $content)
        ```
        """
        
        // Simulate streaming
        Task {
            for character in response {
                currentResponse.append(character)
                try? await Task.sleep(nanoseconds: 8_000_000) // 8ms per character
            }
            
            await MainActor.run {
                messages.append(Message(
                    content: currentResponse,
                    isUser: false,
                    timestamp: Date()
                ))
                currentResponse = ""
                isReceiving = false
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

@available(iOS 15.0, macOS 12.0, *)
struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                MarkdownView(message.content, options: .chat)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isUser ? Color.blue : Color.gray.opacity(0.15))
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 300)
            
            if !message.isUser { Spacer() }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct StreamingMessageView: View {
    @Binding var content: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                StreamingMarkdownView(content: $content, options: .chat)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                    )
                
                HStack(spacing: 4) {
                    ProgressView()
                        .scaleEffect(0.5)
                    Text("Typing...")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: 300)
            
            Spacer()
        }
    }
}

#endif