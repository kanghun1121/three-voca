import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Networking",
    targets: [
        .networking(interface: .init(
            dependencies: [.dependencies]
        )),
        .networking(implements: .init(
            dependencies: [
                .networkingInterface,
                .dependencies,
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
