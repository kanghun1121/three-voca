import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "UseCase",
    targets: [
        .useCase(interface: .init(
            dependencies: [.dependencies]
        )),
        .useCase(implements: .init(
            dependencies: [
                .useCaseInterface,
                .core,
                .dependencies,
            ]
        )),
        .useCase(tests: .init(
            dependencies: [
                .useCase,
                .useCaseInterface,
                .core,
                .dependencies,
            ]
        )),
        .useCase(example: .init(
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:]
                ],
                "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)"
            ]),
            dependencies: [
                .useCase,
                .useCaseInterface,
                .dependencies,
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "../App/Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "../App/Secrets.xcconfig")
                ]
            )
        )),
    ],
    schemes: [
        .scheme(
            name: "UseCaseExample",
            buildAction: .buildAction(targets: [.target("UseCaseExample")]),
            runAction: .runAction(executable: .target("UseCaseExample"))
        )
    ]
)
