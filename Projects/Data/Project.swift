import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Data",
    targets: [
        .data(factory: .init(
            dependencies: [
                .domainInterface,
                .core,
                .networking,
                .networkingInterface,
                .dependencies,
            ]
        )),
        .data(tests: .init(
            dependencies: [
                .data,
                .domainInterface,
                .networkingInterface,
                .dependencies,
            ]
        )),
    ]
)
