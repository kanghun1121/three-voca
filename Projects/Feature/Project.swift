import ProjectDescription
import DependencyPlugin

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .core,
            .feature(implements: .home),
            .feature(implements: .session),
            .feature(implements: .vocabulary),
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
