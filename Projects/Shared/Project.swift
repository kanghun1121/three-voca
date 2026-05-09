import ProjectDescription
import DependencyPlugin

let targets: [Target] = [
    .shared(factory: .init(dependencies: []))
]

let project = Project.makeModule(name: "Shared", targets: targets)
