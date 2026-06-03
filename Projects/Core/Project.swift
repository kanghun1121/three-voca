import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Core",
    targets: [
        .core(factory: .init(dependencies: [.shared]))
    ]
)
