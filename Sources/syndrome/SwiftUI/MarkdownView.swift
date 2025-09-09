//
//  MarkdownView.swift
//  syndrome
//
//  SwiftUI components for rendering Markdown content
//

#if canImport(SwiftUI) && (canImport(UIKit) || canImport(AppKit))
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// A SwiftUI view that renders Markdown content.
public struct MarkdownView: View {
    private let content: String
    private let options: MarkdownRenderingOptions
    @State private var attributedString: AttributedString = AttributedString()
    
    /// Creates a new MarkdownView with the specified content and options.
    /// - Parameters:
    ///   - content: The Markdown content to render.
    ///   - options: The rendering options to use. Defaults to `.default`.
    public init(_ content: String, options: MarkdownRenderingOptions = .default) {
        self.content = content
        self.options = options
    }
    
    public var body: some View {
        Text(attributedString)
            .textSelection(.enabled)
            .onAppear {
                updateAttributedString()
            }
            .onChange(of: content) { _ in
                updateAttributedString()
            }
    }
    
    private func updateAttributedString() {
        let document = MarkdownParser.parse(content)
        let nsAttributedString = document.attributedString(options: options)
        
        // Convert NSAttributedString to AttributedString with proper attribute scopes
        #if canImport(UIKit)
        do {
            attributedString = try AttributedString(nsAttributedString, including: \.uiKit)
        } catch {
            // Try foundation scope as fallback
            do {
                attributedString = try AttributedString(nsAttributedString, including: \.foundation)
            } catch {
                // Last resort: plain text from parsed document
                attributedString = AttributedString(nsAttributedString.string)
            }
        }
        #elseif canImport(AppKit)
        do {
            attributedString = try AttributedString(nsAttributedString, including: \.appKit)
        } catch {
            // Try foundation scope as fallback
            do {
                attributedString = try AttributedString(nsAttributedString, including: \.foundation)
            } catch {
                // Last resort: plain text from parsed document
                attributedString = AttributedString(nsAttributedString.string)
            }
        }
        #else
        // For other platforms, use foundation scope
        do {
            attributedString = try AttributedString(nsAttributedString, including: \.foundation)
        } catch {
            // Last resort: plain text from parsed document
            attributedString = AttributedString(nsAttributedString.string)
        }
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// A SwiftUI view modifier for applying markdown rendering options.
public struct MarkdownOptionsModifier: ViewModifier {
    let options: MarkdownRenderingOptions
    
    public func body(content: Content) -> some View {
        content.environment(\.markdownOptions, options)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// Environment key for markdown rendering options.
private struct MarkdownOptionsKey: EnvironmentKey {
    static let defaultValue = MarkdownRenderingOptions.default
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension EnvironmentValues {
    /// The markdown rendering options to use in this environment.
    public var markdownOptions: MarkdownRenderingOptions {
        get { self[MarkdownOptionsKey.self] }
        set { self[MarkdownOptionsKey.self] = newValue }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension View {
    /// Applies the specified markdown rendering options to this view.
    /// - Parameter options: The rendering options to apply.
    /// - Returns: A view with the specified markdown options.
    public func markdownOptions(_ options: MarkdownRenderingOptions) -> some View {
        modifier(MarkdownOptionsModifier(options: options))
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// A SwiftUI Text extension for inline markdown rendering.
extension Text {
    /// Creates a Text view with rendered markdown content.
    /// - Parameters:
    ///   - markdown: The markdown content to render.
    ///   - options: The rendering options to use. Defaults to `.default`.
    public init(markdown: String, options: MarkdownRenderingOptions = .default) {
        let document = MarkdownParser.parse(markdown)
        let nsAttributedString = document.attributedString(options: options)
        
        // Convert NSAttributedString to AttributedString with proper attribute scopes
        #if canImport(UIKit)
        do {
            let converted = try AttributedString(nsAttributedString, including: \.uiKit)
            self.init(converted)
        } catch {
            // Try foundation scope as fallback
            do {
                let converted = try AttributedString(nsAttributedString, including: \.foundation)
                self.init(converted)
            } catch {
                // Last resort: plain text from parsed document
                self.init(nsAttributedString.string)
            }
        }
        #elseif canImport(AppKit)
        do {
            let converted = try AttributedString(nsAttributedString, including: \.appKit)
            self.init(converted)
        } catch {
            // Try foundation scope as fallback
            do {
                let converted = try AttributedString(nsAttributedString, including: \.foundation)
                self.init(converted)
            } catch {
                // Last resort: plain text from parsed document
                self.init(nsAttributedString.string)
            }
        }
        #else
        // For other platforms, use foundation scope
        do {
            let converted = try AttributedString(nsAttributedString, including: \.foundation)
            self.init(converted)
        } catch {
            // Last resort: plain text from parsed document
            self.init(nsAttributedString.string)
        }
        #endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// A streaming markdown view that efficiently handles incremental updates.
public struct StreamingMarkdownView: View {
    @Binding private var content: String
    private let options: MarkdownRenderingOptions
    @State private var attributedString: AttributedString = AttributedString()
    
    /// Creates a new StreamingMarkdownView with bound content and options.
    /// - Parameters:
    ///   - content: A binding to the markdown content to render.
    ///   - options: The rendering options to use. Defaults to `.default`.
    public init(content: Binding<String>, options: MarkdownRenderingOptions = .default) {
        self._content = content
        self.options = options
    }
    
    public var body: some View {
        Text(attributedString)
            .textSelection(.enabled)
            .onAppear {
                updateAttributedString()
            }
            .onChange(of: content) { _ in
                updateAttributedString()
            }
    }
    
    private func updateAttributedString() {
        // For streaming text, we parse on every update
        // Future optimization: implement incremental parsing
        let document = MarkdownParser.parse(content)
        let nsAttributedString = document.attributedString(options: options)
        
        // Convert NSAttributedString to AttributedString with proper attribute scopes
        #if canImport(UIKit)
        do {
            attributedString = try AttributedString(nsAttributedString, including: \.uiKit)
        } catch {
            // Try foundation scope as fallback
            do {
                attributedString = try AttributedString(nsAttributedString, including: \.foundation)
            } catch {
                // Last resort: plain text from parsed document
                attributedString = AttributedString(nsAttributedString.string)
            }
        }
        #elseif canImport(AppKit)
        do {
            attributedString = try AttributedString(nsAttributedString, including: \.appKit)
        } catch {
            // Try foundation scope as fallback
            do {
                attributedString = try AttributedString(nsAttributedString, including: \.foundation)
            } catch {
                // Last resort: plain text from parsed document
                attributedString = AttributedString(nsAttributedString.string)
            }
        }
        #else
        // For other platforms, use foundation scope
        do {
            attributedString = try AttributedString(nsAttributedString, including: \.foundation)
        } catch {
            // Last resort: plain text from parsed document
            attributedString = AttributedString(nsAttributedString.string)
        }
        #endif
    }
}

#endif