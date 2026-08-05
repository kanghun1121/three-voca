import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "DesignSystem",
    targets: [
        .shared(implements: .designSystem, factory: .init(
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        ))
    ]
)
