import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Data",
    targets: [
        .data(factory: .init(
            resources: ["Resources/**"],
            dependencies: [
                .domainInterface,
                .core,
                .networkingInterface,
                .dependencies,
                .dependenciesMacros,
            ]
        )),
        .data(tests: .init(
            infoPlist: .extendingDefault(with: [
                "SUPABASE_URL": "https://supabase.invalid"
            ]),
            dependencies: [
                .data,
                .domainInterface,
                .networkingInterface,
                .dependencies,
            ]
        )),
    ]
)
