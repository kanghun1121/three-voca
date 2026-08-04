import ProjectDescription

// MARK: - Layer aggregators

public extension TargetDependency {
    static let feature: TargetDependency = .project(
        target: "Feature",
        path: .relativeToRoot("Projects/Feature")
    )
    static let core: TargetDependency = .project(
        target: "Core",
        path: .relativeToRoot("Projects/Core")
    )
    static let shared: TargetDependency = .project(
        target: "Shared",
        path: .relativeToRoot("Projects/Shared")
    )
}

// MARK: - UseCase shorthands

public extension TargetDependency {
    static let useCaseInterface: TargetDependency = .project(
        target: "UseCaseInterface",
        path: .relativeToRoot("Projects/UseCase")
    )
    static let useCase: TargetDependency = .project(
        target: "UseCase",
        path: .relativeToRoot("Projects/UseCase")
    )
}

// MARK: - Data shorthand

public extension TargetDependency {
    static let data: TargetDependency = .project(
        target: "Data",
        path: .relativeToRoot("Projects/Data")
    )
}

// MARK: - Shared sub-module shorthands

public extension TargetDependency {
    static func shared(implements module: ModulePath.Shared) -> TargetDependency {
        .project(
            target: module.rawValue,
            path: .relativeToRoot("Projects/Shared/\(module.rawValue)")
        )
    }

    static let designSystem: TargetDependency = .shared(implements: .designSystem)
}

// MARK: - Feature sub-module shorthands

public extension TargetDependency {
    static func feature(implements module: ModulePath.Feature) -> TargetDependency {
        .project(
            target: "Feature\(module.rawValue)",
            path: .relativeToRoot("Projects/Feature/\(module.rawValue)")
        )
    }
}
