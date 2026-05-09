import ProjectDescription
import DependencyPlugin

let targets: [Target] = [
    .core(factory: .init(dependencies: [.shared]))
]

let project = Project.makeModule(name: "Core", targets: targets)
