import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Data",
    targets: [
        .data(factory: .init(
            dependencies: [
                .domainInterface,
                .networkingInterface,
                .dependencies,
            ]
        )),
    ]
)
