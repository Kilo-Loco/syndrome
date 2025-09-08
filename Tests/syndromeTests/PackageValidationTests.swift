import Testing
import Foundation
@testable import syndrome

@Suite("Package Structure Validation")
struct PackageValidationTests {
    
    @Test("Package manifest exists")
    func testPackageManifestExists() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let manifestPath = packagePath.appendingPathComponent("Package.swift")
        #expect(FileManager.default.fileExists(atPath: manifestPath.path))
    }
    
    @Test("Source directory structure is correct")
    func testSourceDirectoryStructure() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let sourcesPath = packagePath.appendingPathComponent("Sources")
        #expect(FileManager.default.fileExists(atPath: sourcesPath.path))
        
        let syndromePath = sourcesPath.appendingPathComponent("syndrome")
        #expect(FileManager.default.fileExists(atPath: syndromePath.path))
        
        let parserPath = syndromePath.appendingPathComponent("Parser")
        #expect(FileManager.default.fileExists(atPath: parserPath.path))
        
        let modelsPath = syndromePath.appendingPathComponent("Models")
        #expect(FileManager.default.fileExists(atPath: modelsPath.path))
        
        let extensionsPath = syndromePath.appendingPathComponent("Extensions")
        #expect(FileManager.default.fileExists(atPath: extensionsPath.path))
    }
    
    @Test("Test directory structure is correct")
    func testTestDirectoryStructure() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let testsPath = packagePath.appendingPathComponent("Tests")
        #expect(FileManager.default.fileExists(atPath: testsPath.path))
        
        let syndromeTestsPath = testsPath.appendingPathComponent("syndromeTests")
        #expect(FileManager.default.fileExists(atPath: syndromeTestsPath.path))
        
        let parserTestsPath = syndromeTestsPath.appendingPathComponent("ParserTests")
        #expect(FileManager.default.fileExists(atPath: parserTestsPath.path))
        
        let modelTestsPath = syndromeTestsPath.appendingPathComponent("ModelTests")
        #expect(FileManager.default.fileExists(atPath: modelTestsPath.path))
        
        let integrationTestsPath = syndromeTestsPath.appendingPathComponent("IntegrationTests")
        #expect(FileManager.default.fileExists(atPath: integrationTestsPath.path))
    }
    
    @Test("Documentation directory exists")
    func testDocumentationDirectoryExists() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let documentationPath = packagePath.appendingPathComponent("Documentation")
        #expect(FileManager.default.fileExists(atPath: documentationPath.path))
    }
    
    @Test("Examples directory exists")
    func testExamplesDirectoryExists() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let examplesPath = packagePath.appendingPathComponent("Examples")
        #expect(FileManager.default.fileExists(atPath: examplesPath.path))
        
        // Check for actual example files
        let renderingExamplePath = examplesPath.appendingPathComponent("RenderingExample.swift")
        #expect(FileManager.default.fileExists(atPath: renderingExamplePath.path))
        
        let swiftUIExamplePath = examplesPath.appendingPathComponent("SwiftUIExample.swift")
        #expect(FileManager.default.fileExists(atPath: swiftUIExamplePath.path))
        
        let chatAppExamplePath = examplesPath.appendingPathComponent("ChatAppExample.swift")
        #expect(FileManager.default.fileExists(atPath: chatAppExamplePath.path))
    }
    
    @Test("Public API is exposed")
    func testPublicAPIExposed() {
        let markdown = syndrome()
        #expect(markdown != nil)
        #expect(syndrome.version == "1.0.0")
    }
    
    @Test("Package name is correct")
    func testPackageNameIsCorrect() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let manifestPath = packagePath.appendingPathComponent("Package.swift")
        let manifestContent = try String(contentsOf: manifestPath, encoding: .utf8)
        
        #expect(manifestContent.contains("name: \"syndrome\""))
    }
    
    @Test("Minimum Swift version is 5.9")
    func testMinimumSwiftVersion() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let manifestPath = packagePath.appendingPathComponent("Package.swift")
        let manifestContent = try String(contentsOf: manifestPath, encoding: .utf8)
        
        #expect(manifestContent.contains("swift-tools-version: 5.9"))
    }
    
    @Test("Package has no external dependencies")
    func testPackageDependenciesAreResolved() throws {
        let packagePath = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let manifestPath = packagePath.appendingPathComponent("Package.swift")
        let manifestContent = try String(contentsOf: manifestPath, encoding: .utf8)
        
        #expect(manifestContent.contains("dependencies: ["))
        
        let dependenciesRegex = try NSRegularExpression(
            pattern: "dependencies:\\s*\\[\\s*\\]",
            options: []
        )
        let range = NSRange(location: 0, length: manifestContent.utf16.count)
        let matches = dependenciesRegex.matches(in: manifestContent, options: [], range: range)
        
        #expect(matches.count > 0)
    }
}