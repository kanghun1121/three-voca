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
                "SUPABASE_URL": "$(SUPABASE_PROD_URL)"
            ]),
            dependencies: [
                .data,
                .domainInterface,
                .networkingInterface,
                .dependencies,
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "../App/Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "../App/Secrets.xcconfig")
                ]
            )
        )),
    ]
)
