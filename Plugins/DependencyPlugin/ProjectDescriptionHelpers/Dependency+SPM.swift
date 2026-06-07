import ProjectDescription

// MARK: - SPM External

public extension TargetDependency {
    static let dependencies: TargetDependency = .external(name: "Dependencies")
    static let swiftUINavigation: TargetDependency = .external(name: "SwiftUINavigation")
    static let shimmer: TargetDependency = .external(name: "Shimmer")
}
