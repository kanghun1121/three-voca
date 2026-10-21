import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "DesignSystem",
    targets: [
        .designSystem(factory: .init(
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        ))
    ]
)
