// swift-tools-version: 5.10
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:],
        baseSettings: .settings(configurations: [
            .debug(name: "Debug"),
            .debug(name: "Dev"),
            .release(name: "Release")
        ])
    )
#endif

let package = Package(
    name: "FiveVoca",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "1.5.0"),
    ]
)
