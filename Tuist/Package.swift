// swift-tools-version: 5.10
import PackageDescription

#if TUIST
    import ProjectDescription

    // Xcode 27 rejects package targets below iOS 15 and macOS 12.
    // These targets still declare older minimums in their package manifests.
    var packageTargetSettings: [String: Settings] = [:]

    for target in [
        "CasePaths", "CasePathsCore", "Clocks", "CombineSchedulers",
        "ConcurrencyExtras", "CustomDump", "Dependencies", "DependenciesMacros",
        "IssueReporting", "IssueReportingPackageSupport", "SwiftUINavigation",
        "SwiftUINavigationCore", "XCTestDynamicOverlay"
    ] {
        packageTargetSettings[target] = .settings(base: ["IPHONEOS_DEPLOYMENT_TARGET": "15.0"])
    }

    for target in [
        "CasePathsMacros", "DependenciesMacrosPlugin", "SwiftBasicFormat",
        "SwiftCompilerPlugin", "SwiftCompilerPluginMessageHandling", "SwiftDiagnostics",
        "SwiftIfConfig", "SwiftOperators", "SwiftParser", "SwiftParserDiagnostics",
        "SwiftSyntax", "SwiftSyntax509", "SwiftSyntax510", "SwiftSyntax600",
        "SwiftSyntax601", "SwiftSyntax602", "SwiftSyntax603", "SwiftSyntaxBuilder",
        "SwiftSyntaxMacroExpansion", "SwiftSyntaxMacros", "_SwiftSyntaxCShims"
    ] {
        packageTargetSettings[target] = .settings(base: ["MACOSX_DEPLOYMENT_TARGET": "12.0"])
    }

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:],
        baseSettings: .settings(configurations: [
            .debug(name: "Debug"),
            .debug(name: "Dev"),
            .release(name: "Release")
        ]),
        targetSettings: packageTargetSettings
    )
#endif

let package = Package(
    name: "FiveVoca",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.5.0"),
        .package(url: "https://github.com/kanghun1121/MarkdownRenderer.git", from: "0.4.0"),
    ]
)
