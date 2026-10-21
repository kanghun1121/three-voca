// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DependencyPlugin",
    products: [
        .library(name: "DependencyPlugin", targets: ["DependencyPlugin"])
    ],
    targets: [
        .target(name: "DependencyPlugin", path: "ProjectDescriptionHelpers")
    ]
)
