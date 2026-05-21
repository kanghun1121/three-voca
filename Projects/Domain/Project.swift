import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Domain",
    targets: [
        .domain(interface: .init(
            dependencies: [.dependencies]
        )),
        .domain(implements: .init(
            dependencies: [
                .domainInterface,
                .core,
                .dependencies,
            ]
        )),
    ]
)
