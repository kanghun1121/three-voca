import ProjectDescription
import DependencyPlugin

let targets: [Target] = [
    .feature(factory: .init(
        dependencies: [
            .feature(implements: .home),
            .feature(implements: .session),
            .feature(implements: .vocabulary),
        ]
    ))
]

let project = Project.makeModule(name: "Feature", targets: targets)
