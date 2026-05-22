import ProjectDescription

public extension TargetDependency {
    static let dependencies: TargetDependency = .external(name: "Dependencies")
    static let swiftUINavigation: TargetDependency = .external(name: "SwiftUINavigation")
}
