import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Networking",
    targets: [
        .networking(interface: .init(
            dependencies: [.dependencies, .core, .dependenciesMacros]
        )),
        .networking(implements: .init(
            dependencies: [
                .networkingInterface,
                .dependencies,
                .core,
            ]
        )),
        .networking(tests: .init(
            dependencies: [
                .networking,
                .networkingInterface,
                .dependencies,
            ]
        )),
    ]
)
