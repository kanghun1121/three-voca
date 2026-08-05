import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Core",
    targets: [
        .core(factory: .init(dependencies: [.dependencies])),
        .core(tests: .init(dependencies: [.core])),
    ]
)
