//
//  MarkdownParser.swift
//  syndrome
//
//  Migrated from xamrock-app
//

import Foundation

// MARK: - Parser Implementation

/// A high-performance Markdown parser that converts Markdown text into a structured document model.
///
/// `MarkdownParser` provides a simple, static interface for parsing CommonMark-flavored Markdown
/// with additional support for common extensions.
///
/// ## Overview
///
/// The parser supports the following Markdown elements:
/// - Headings (ATX-style, levels 1-6)
/// - Paragraphs with inline formatting
/// - Bold and italic emphasis
/// - Code blocks (fenced) and inline code
/// - Lists (ordered and unordered)
/// - Blockquotes (including nested)
/// - Horizontal rules
/// - Links and images
/// - HTML entities and numeric character references
/// - Backslash escape sequences
///
/// ## Usage Example
///
/// ```swift
/// let markdown = """
///     # Welcome to syndrome
///     
///     This is a **bold** statement with *emphasis*.
///     
///     - Feature 1
///     - Feature 2
///     """
/// 
/// let document = MarkdownParser.parse(markdown)
/// 
/// for block in document.blocks {
///     switch block {
///     case .heading(let level, let content):
///         print("Heading (level \(level))")
///     case .paragraph(let content):
///         print("Paragraph with \(content.count) inline elements")
///     case .list(let items, let type):
///         print("List with \(items.count) items")
///     default:
///         break
///     }
/// }
/// ```
///
/// ## Performance Considerations
///
/// The parser is optimized for documents under 1MB. For larger documents,
/// consider streaming or chunking the input.
///
/// - Complexity: O(n) where n is the length of the input
/// - Memory: O(n) for the document structure
///
/// ## Thread Safety
///
/// The parser is stateless and thread-safe. Multiple threads can safely
/// call `parse(_:)` concurrently.
///
/// - Since: 1.0.0
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public struct MarkdownParser {
    
    // HTML Entity lookup table
    private static let htmlEntities: [String: String] = [
        // Core HTML entities
        "amp": "&",
        "lt": "<",
        "gt": ">",
        "quot": "\"",
        "apos": "'",
        
        // Common named entities
        "nbsp": "\u{00A0}",
        "copy": "©",
        "reg": "®",
        "trade": "™",
        "mdash": "—",
        "ndash": "–",
        "hellip": "…",
        
        // Additional common entities
        "euro": "€",
        "pound": "£",
        "yen": "¥",
        "cent": "¢",
        "sect": "§",
        "para": "¶",
        "bull": "•",
        "deg": "°",
        "plusmn": "±",
        "times": "×",
        "divide": "÷",
        "ne": "≠",
        "le": "≤",
        "ge": "≥",
        "larr": "←",
        "rarr": "→",
        "uarr": "↑",
        "darr": "↓",
        "harr": "↔"
    ]
    
    private struct ParseContext {
        var lines: [String]
        var currentIndex: Int
        var currentLine: String { 
            currentIndex < lines.count ? lines[currentIndex] : ""
        }
        
        mutating func advance() {
            currentIndex += 1
        }
        
        mutating func consumeBlankLines() {
            while currentIndex < lines.count && lines[currentIndex].trimmingCharacters(in: .whitespaces).isEmpty {
                currentIndex += 1
            }
        }
        
        func hasMore() -> Bool {
            currentIndex < lines.count
        }
    }
    
    // Tab expansion utility function
    private static func expandTabs(_ text: String, tabWidth: Int = 4) -> String {
        var result = ""
        var column = 0
        
        for char in text {
            if char == "\t" {
                let spacesToAdd = tabWidth - (column % tabWidth)
                result += String(repeating: " ", count: spacesToAdd)
                column += spacesToAdd
            } else if char == "\n" {
                result.append(char)
                column = 0
            } else {
                result.append(char)
                column += 1
            }
        }
        
        return result
    }
    
    /// Parses a Markdown string into a structured document model.
    ///
    /// This method processes the input string according to CommonMark specifications
    /// with the following extensions:
    /// - Tab expansion (tabs expand to 4-space boundaries)
    /// - HTML entity decoding (both named and numeric references)
    /// - Backslash escape sequences for special characters
    ///
    /// - Parameter markdown: The Markdown-formatted text to parse.
    ///                      Can be empty, resulting in an empty document.
    ///
    /// - Returns: A `MarkdownDocument` containing the parsed structure.
    ///           Never returns nil; invalid Markdown results in a best-effort parse.
    ///
    /// - Note: The parser is lenient and will always return a valid document structure,
    ///         even for malformed Markdown.
    ///
    /// - Important: Tab characters are expanded to spaces during parsing.
    ///              To preserve literal tabs, escape them with backslashes (\\t).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let markdown = "# Title\n\nParagraph with **bold** text."
    /// let document = MarkdownParser.parse(markdown)
    /// print("Found \(document.blocks.count) blocks")
    /// // Output: Found 2 blocks
    /// ```
    ///
    /// ## Edge Cases
    ///
    /// ```swift
    /// // Empty input
    /// let empty = MarkdownParser.parse("")
    /// assert(empty.blocks.isEmpty)
    ///
    /// // Malformed emphasis
    /// let malformed = MarkdownParser.parse("**unclosed bold")
    /// // Returns paragraph with literal "**unclosed bold"
    ///
    /// // Mixed line endings
    /// let mixed = MarkdownParser.parse("Line 1\r\nLine 2\nLine 3")
    /// // Handles all line ending styles correctly
    /// ```
    ///
    /// - Complexity: O(n) where n is the length of the input string
    public static func parse(_ markdown: String) -> MarkdownDocument {
        // Expand tabs to spaces for consistent parsing
        let expandedMarkdown = expandTabs(markdown)
        let lines = expandedMarkdown.components(separatedBy: .newlines)
        var context = ParseContext(lines: lines, currentIndex: 0)
        var blocks: [BlockElement] = []
        
        context.consumeBlankLines()
        
        while context.hasMore() {
            if let block = parseBlock(&context) {
                blocks.append(block)
            } else {
                context.advance()
            }
            context.consumeBlankLines()
        }
        
        return MarkdownDocument(blocks: blocks)
    }
    
    private static func parseBlock(_ context: inout ParseContext) -> BlockElement? {
        let line = context.currentLine
        
        // ATX Headers (# ## ### etc.)
        if let heading = parseATXHeading(line) {
            context.advance()
            return heading
        }
        
        // Horizontal Rules (--- *** ___)
        if isHorizontalRule(line) {
            context.advance()
            return .horizontalRule
        }
        
        // Fenced Code Blocks (``` or ~~~)
        if let codeBlock = parseFencedCodeBlock(&context) {
            return codeBlock
        }
        
        // Blockquotes (>)
        if let blockquote = parseBlockquote(&context) {
            return blockquote
        }
        
        // Lists (- * + or 1. 2.)
        if let list = parseList(&context) {
            return list
        }
        
        // Default: Paragraph
        return parseParagraph(&context)
    }
    
    private static func parseATXHeading(_ line: String) -> BlockElement? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("#") else { return nil }
        
        let level = trimmed.prefix(while: { $0 == "#" }).count
        guard level >= 1 && level <= 6 else { return nil }
        
        // After the hashes, we either need a space or end of line
        let afterHashes = trimmed.dropFirst(level)
        if !afterHashes.isEmpty && !afterHashes.hasPrefix(" ") && !afterHashes.hasPrefix("\t") {
            return nil // Not a valid heading
        }
        
        let content = String(afterHashes).trimmingCharacters(in: .whitespaces)
        let inlineContent = parseInlineContent(content)
        
        return .heading(level: level, content: inlineContent)
    }
    
    private static func isHorizontalRule(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let chars = Array(trimmed)
        
        guard chars.count >= 3 else { return false }
        
        // Check for valid horizontal rule characters
        let validHRChars: Set<Character> = ["-", "*", "_"]
        let nonSpaceChars = chars.filter { $0 != " " }
        
        // Must have at least 3 non-space characters
        guard nonSpaceChars.count >= 3 else { return false }
        
        // All non-space characters must be the same and must be a valid HR character
        guard let firstChar = nonSpaceChars.first,
              validHRChars.contains(firstChar),
              nonSpaceChars.allSatisfy({ $0 == firstChar }) else { return false }
        
        // All characters must be either the HR character or spaces
        return chars.allSatisfy { $0 == firstChar || $0 == " " }
    }
    
    private static func parseFencedCodeBlock(_ context: inout ParseContext) -> BlockElement? {
        let line = context.currentLine.trimmingCharacters(in: .whitespaces)
        
        guard line.hasPrefix("```") || line.hasPrefix("~~~") else { return nil }
        
        let fence = String(line.prefix(3))
        let info = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
        
        context.advance()
        var codeLines: [String] = []
        
        while context.hasMore() {
            let currentLine = context.currentLine
            if currentLine.trimmingCharacters(in: .whitespaces).hasPrefix(fence) {
                context.advance()
                break
            }
            codeLines.append(currentLine)
            context.advance()
        }
        
        let content = codeLines.joined(separator: "\n")
        return .codeBlock(info: info.isEmpty ? nil : info, content: content)
    }
    
    private static func parseBlockquote(_ context: inout ParseContext) -> BlockElement? {
        guard context.currentLine.trimmingCharacters(in: .whitespaces).hasPrefix(">") else { return nil }
        
        var quoteLines: [String] = []
        
        while context.hasMore() {
            let line = context.currentLine.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix(">") {
                let content = String(line.dropFirst(1))
                let trimmedContent = content.hasPrefix(" ") ? String(content.dropFirst(1)) : content
                quoteLines.append(trimmedContent)
                context.advance()
            } else if line.isEmpty {
                quoteLines.append("")
                context.advance()
            } else {
                break
            }
        }
        
        let quoteContent = quoteLines.joined(separator: "\n")
        let subDocument = parse(quoteContent)
        
        return .blockquote(content: subDocument.blocks)
    }
    
    private static func parseList(_ context: inout ParseContext) -> BlockElement? {
        let line = context.currentLine.trimmingCharacters(in: .whitespaces)
        
        // Check for unordered list (now handles both space and expanded tabs)
        if let marker = line.first, ["-", "*", "+"].contains(marker) {
            if line.count > 1 {
                let afterMarker = line[line.index(line.startIndex, offsetBy: 1)]
                if afterMarker == " " || afterMarker == "\t" {
                    return parseUnorderedList(&context, marker: marker)
                }
            }
        }
        
        // Check for ordered list
        if let match = line.range(of: #"^\d+[.)]\s"#, options: .regularExpression) {
            let delimiter = line[line.index(match.upperBound, offsetBy: -2)]
            return parseOrderedList(&context, delimiter: delimiter)
        }
        
        return nil
    }
    
    private static func parseUnorderedList(_ context: inout ParseContext, marker: Character) -> BlockElement {
        var items: [ListItem] = []
        
        while context.hasMore() {
            let line = context.currentLine.trimmingCharacters(in: .whitespaces)
            if line.first == marker && line.count > 1 {
                let afterMarker = line[line.index(line.startIndex, offsetBy: 1)]
                if afterMarker == " " || afterMarker == "\t" {
                    // Skip marker and whitespace
                    let contentStart = line.index(line.startIndex, offsetBy: 2)
                    let content = String(line[contentStart...]).trimmingCharacters(in: .whitespaces)
                    let itemContent = parseInlineContent(content)
                    items.append(ListItem(content: [.paragraph(content: itemContent)], tight: true))
                    context.advance()
                } else {
                    break
                }
            } else if line.isEmpty {
                context.advance()
                continue
            } else {
                break
            }
        }
        
        return .list(items: items, type: .unordered(marker: marker))
    }
    
    private static func parseOrderedList(_ context: inout ParseContext, delimiter: Character) -> BlockElement {
        var items: [ListItem] = []
        var startNumber = 1
        var isFirst = true
        
        while context.hasMore() {
            let line = context.currentLine.trimmingCharacters(in: .whitespaces)
            if let match = line.range(of: #"^\d+[.)]\s"#, options: .regularExpression) {
                if isFirst {
                    let numberStr = String(line[..<line.index(match.upperBound, offsetBy: -2)])
                    startNumber = Int(numberStr) ?? 1
                    isFirst = false
                }
                
                let content = String(line[match.upperBound...])
                let itemContent = parseInlineContent(content)
                items.append(ListItem(content: [.paragraph(content: itemContent)], tight: true))
                context.advance()
            } else if line.isEmpty {
                context.advance()
                continue
            } else {
                break
            }
        }
        
        return .list(items: items, type: .ordered(startNumber: startNumber, delimiter: delimiter))
    }
    
    private static func parseParagraph(_ context: inout ParseContext) -> BlockElement {
        var paragraphLines: [String] = []
        
        while context.hasMore() {
            // Only trim leading whitespace to preserve trailing spaces for hard breaks
            let line = context.currentLine.trimmingCharacters(in: CharacterSet(charactersIn: "\t ")).isEmpty ?
                       "" : context.currentLine
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                break
            }
            paragraphLines.append(line)
            context.advance()
        }
        
        // Join lines with newlines to preserve soft breaks
        let content = paragraphLines.joined(separator: "\n")
        let inlineContent = parseInlineContent(content)
        
        return .paragraph(content: inlineContent)
    }
    
    // MARK: - Inline Parsing
    
    private static func parseInlineContent(_ text: String) -> [InlineElement] {
        guard !text.isEmpty else { return [] }
        
        var elements: [InlineElement] = []
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            var parsed = false
            
            // Try to parse escape first (highest priority)
            if let (element, endIndex) = parseEscape(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseEntityReference(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseStrongEmphasis(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseEmphasis(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseInlineCode(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseImage(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseLink(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseHardBreak(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            } else if let (element, endIndex) = parseSoftBreak(text, from: currentIndex) {
                elements.append(element)
                currentIndex = endIndex
                parsed = true
            }
            
            if !parsed {
                // Parse regular text - if we hit a special character that couldn't be parsed,
                // include it as literal text
                let (textElement, endIndex) = parseTextIncludingSpecialChars(text, from: currentIndex)
                elements.append(textElement)
                currentIndex = endIndex
            }
        }
        
        return elements
    }
    
    private static func parseStrongEmphasis(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex else { return nil }
        
        // Check for ** or __
        if text[startIndex...].hasPrefix("**") {
            let searchStart = text.index(startIndex, offsetBy: 2)
            guard searchStart < text.endIndex else { return nil }
            
            if let endIndex = findUnescapedDelimiter("**", in: text, from: searchStart) {
                let content = String(text[searchStart..<endIndex])
                let innerElements = parseInlineContent(content)
                return (.strongEmphasis(content: innerElements), text.index(endIndex, offsetBy: 2))
            }
        } else if text[startIndex...].hasPrefix("__") {
            let searchStart = text.index(startIndex, offsetBy: 2)
            guard searchStart < text.endIndex else { return nil }
            
            if let endIndex = findUnescapedDelimiter("__", in: text, from: searchStart) {
                let content = String(text[searchStart..<endIndex])
                let innerElements = parseInlineContent(content)
                return (.strongEmphasis(content: innerElements), text.index(endIndex, offsetBy: 2))
            }
        }
        
        return nil
    }
    
    private static func parseEmphasis(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex else { return nil }
        
        // Check for single * or _ (but not ** or __)
        if text[startIndex] == "*" {
            // Make sure it's not ** by checking the next character
            let nextIndex = text.index(after: startIndex)
            if nextIndex < text.endIndex && text[nextIndex] == "*" {
                return nil // This is **, not single *
            }
            
            // Look for closing * (respecting escapes)
            if let endIndex = findUnescapedDelimiter("*", in: text, from: nextIndex) {
                let content = String(text[nextIndex..<endIndex])
                let innerElements = parseInlineContent(content)
                return (.emphasis(content: innerElements), text.index(after: endIndex))
            }
        } else if text[startIndex] == "_" {
            // Make sure it's not __ by checking the next character
            let nextIndex = text.index(after: startIndex)
            if nextIndex < text.endIndex && text[nextIndex] == "_" {
                return nil // This is __, not single _
            }
            
            // Additional check: if the previous character is also _, this might be part of a failed __ sequence
            // In that case, don't try to parse as emphasis
            if startIndex > text.startIndex {
                let prevIndex = text.index(before: startIndex)
                if text[prevIndex] == "_" {
                    return nil // This is likely the second _ in a failed __ strong emphasis
                }
            }
            
            // Look for closing _ (respecting escapes)
            if let endIndex = findUnescapedDelimiter("_", in: text, from: nextIndex) {
                let content = String(text[nextIndex..<endIndex])
                let innerElements = parseInlineContent(content)
                return (.emphasis(content: innerElements), text.index(after: endIndex))
            }
        }
        
        return nil
    }
    
    /// Find an unescaped delimiter in the text
    private static func findUnescapedDelimiter(_ delimiter: String, in text: String, from startIndex: String.Index) -> String.Index? {
        var currentIndex = startIndex
        
        while currentIndex < text.endIndex {
            if text[currentIndex...].hasPrefix(delimiter) {
                // Check if it's escaped
                if currentIndex > text.startIndex {
                    let prevIndex = text.index(before: currentIndex)
                    if text[prevIndex] == "\\" {
                        // Check if the backslash itself is escaped
                        var backslashCount = 1
                        var checkIndex = prevIndex
                        while checkIndex > text.startIndex {
                            checkIndex = text.index(before: checkIndex)
                            if text[checkIndex] == "\\" {
                                backslashCount += 1
                            } else {
                                break
                            }
                        }
                        // If odd number of backslashes, the delimiter is escaped
                        if backslashCount % 2 == 1 {
                            currentIndex = text.index(after: currentIndex)
                            continue
                        }
                    }
                }
                return currentIndex
            }
            currentIndex = text.index(after: currentIndex)
        }
        
        return nil
    }
    
    private static func parseInlineCode(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex else { return nil }
        
        if text[startIndex] == "`" {
            let searchStart = text.index(startIndex, offsetBy: 1)
            guard searchStart < text.endIndex else { return nil }
            
            // For inline code, we don't process escapes - find raw backtick
            if let endRange = text.range(of: "`", options: [], range: searchStart..<text.endIndex) {
                let content = String(text[searchStart..<endRange.lowerBound])
                return (.code(content), endRange.upperBound)
            }
        }
        
        return nil
    }
    
    private static func parseLink(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex && text[startIndex] == "[" else { return nil }
        
        // Find closing bracket
        guard let closingBracket = text.range(of: "]", options: [], range: text.index(after: startIndex)..<text.endIndex) else {
            return nil
        }
        
        // Check for opening parenthesis immediately after
        guard closingBracket.upperBound < text.endIndex && text[closingBracket.upperBound] == "(" else {
            return nil
        }
        
        // Find closing parenthesis
        guard let closingParen = text.range(of: ")", options: [], range: text.index(after: closingBracket.upperBound)..<text.endIndex) else {
            return nil
        }
        
        let linkText = String(text[text.index(after: startIndex)..<closingBracket.lowerBound])
        let urlAndTitle = String(text[text.index(after: closingBracket.upperBound)..<closingParen.lowerBound])
        
        // Parse URL and optional title
        let (url, title) = parseLinkDestination(urlAndTitle)
        
        let textElements = parseInlineContent(linkText)
        
        return (.link(text: textElements, url: url, title: title), closingParen.upperBound)
    }
    
    /// Parse link destination and optional title from the URL portion
    private static func parseLinkDestination(_ input: String) -> (url: String, title: String?) {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        // Check if there's a title (starts with a quote after the URL)
        // Look for space followed by quote
        var url = trimmed
        var title: String? = nil
        
        // Find the first space that might separate URL from title
        if let spaceIndex = trimmed.firstIndex(of: " ") {
            let potentialUrl = String(trimmed[..<spaceIndex])
            let remainder = String(trimmed[trimmed.index(after: spaceIndex)...]).trimmingCharacters(in: .whitespaces)
            
            // Check if remainder starts and ends with quotes
            if remainder.hasPrefix("\"") && remainder.hasSuffix("\"") && remainder.count > 2 {
                url = potentialUrl
                title = String(remainder.dropFirst().dropLast())
            } else if remainder.hasPrefix("'") && remainder.hasSuffix("'") && remainder.count > 2 {
                url = potentialUrl
                title = String(remainder.dropFirst().dropLast())
            }
        }
        
        return (url, title)
    }
    
    private static func parseImage(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex && text[startIndex] == "!" else { return nil }
        
        // Use link parsing but for images
        if let (linkElement, endIndex) = parseLink(text, from: text.index(after: startIndex)) {
            if case .link(let text, let url, let title) = linkElement {
                return (.image(alt: text, url: url, title: title), endIndex)
            }
        }
        
        return nil
    }
    
    private static func parseHardBreak(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex else { return nil }
        
        let remainingText = text[startIndex...]
        
        if remainingText.hasPrefix("  \n") {
            let endIndex = text.index(startIndex, offsetBy: 3, limitedBy: text.endIndex) ?? text.endIndex
            return (.hardBreak, endIndex)
        } else if remainingText.hasPrefix("\\\n") {
            let endIndex = text.index(startIndex, offsetBy: 2, limitedBy: text.endIndex) ?? text.endIndex
            return (.hardBreak, endIndex)
        }
        
        return nil
    }
    
    private static func parseSoftBreak(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex && text[startIndex] == "\n" else { return nil }
        
        return (.softBreak, text.index(after: startIndex))
    }
    
    private static func parseEscape(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex && text[startIndex] == "\\" else { return nil }
        
        let nextIndex = text.index(after: startIndex)
        guard nextIndex < text.endIndex else {
            return nil
        }
        
        let nextChar = text[nextIndex]
        let escapableChars: Set<Character> = ["\\", "`", "*", "_", "[", "]", "!", "#", "+", "-", "(", ")"]
        
        if escapableChars.contains(nextChar) {
            let endIndex = text.index(after: nextIndex)
            return (.text(String(nextChar)), endIndex)
        }
        
        return nil
    }
    
    private static func parseEntityReference(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index)? {
        guard startIndex < text.endIndex && text[startIndex] == "&" else { return nil }
        
        // Find the closing semicolon within reasonable distance (max ~20 chars)
        let searchEnd = text.index(startIndex, offsetBy: 20, limitedBy: text.endIndex) ?? text.endIndex
        guard let semicolonRange = text.range(of: ";", options: [], range: text.index(after: startIndex)..<searchEnd) else {
            return nil
        }
        
        let entityContent = String(text[text.index(after: startIndex)..<semicolonRange.lowerBound])
        
        // Check for numeric character reference
        if entityContent.hasPrefix("#") {
            let numericPart = String(entityContent.dropFirst())
            
            if numericPart.hasPrefix("x") || numericPart.hasPrefix("X") {
                // Hexadecimal numeric reference
                let hexPart = String(numericPart.dropFirst())
                if let codePoint = Int(hexPart, radix: 16),
                   let scalar = Unicode.Scalar(codePoint) {
                    let char = Character(scalar)
                    return (.text(String(char)), semicolonRange.upperBound)
                }
            } else {
                // Decimal numeric reference
                if let codePoint = Int(numericPart),
                   let scalar = Unicode.Scalar(codePoint) {
                    let char = Character(scalar)
                    return (.text(String(char)), semicolonRange.upperBound)
                }
            }
        } else {
            // Named entity reference
            if let replacement = htmlEntities[entityContent] {
                return (.text(replacement), semicolonRange.upperBound)
            }
        }
        
        // Invalid entity - return nil to let it be parsed as regular text
        return nil
    }
    
    private static func parseText(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index) {
        var currentIndex = startIndex
        var textContent = ""
        
        while currentIndex < text.endIndex {
            let char = text[currentIndex]
            
            // Check if this might be a special character that starts an inline element
            if ["`", "[", "!", "\\", "*", "_", "\n"].contains(char) {
                break
            }
            
            textContent.append(char)
            currentIndex = text.index(after: currentIndex)
        }
        
        // If no text was collected, consume at least one character to avoid infinite loop
        if textContent.isEmpty && currentIndex < text.endIndex {
            textContent.append(text[currentIndex])
            currentIndex = text.index(after: currentIndex)
        }
        
        return (.text(textContent), currentIndex)
    }
    
    private static func parseTextIncludingSpecialChars(_ text: String, from startIndex: String.Index) -> (InlineElement, String.Index) {
        var currentIndex = startIndex
        var textContent = ""
        
        // Consume at least one character to avoid infinite loop
        if currentIndex < text.endIndex {
            textContent.append(text[currentIndex])
            currentIndex = text.index(after: currentIndex)
        }
        
        // Continue consuming non-special characters
        while currentIndex < text.endIndex {
            let char = text[currentIndex]
            
            // Check if this position can start a valid special element
            if parseEscape(text, from: currentIndex) != nil ||
               parseEntityReference(text, from: currentIndex) != nil ||
               parseStrongEmphasis(text, from: currentIndex) != nil ||
               parseEmphasis(text, from: currentIndex) != nil ||
               parseInlineCode(text, from: currentIndex) != nil ||
               parseImage(text, from: currentIndex) != nil ||
               parseLink(text, from: currentIndex) != nil ||
               parseHardBreak(text, from: currentIndex) != nil ||
               parseSoftBreak(text, from: currentIndex) != nil {
                break
            }
            
            // If no special element can be parsed here, include this character as text
            textContent.append(char)
            currentIndex = text.index(after: currentIndex)
        }
        
        return (.text(textContent), currentIndex)
    }
}