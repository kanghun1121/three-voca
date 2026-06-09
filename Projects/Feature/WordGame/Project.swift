import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.wordGame.rawValue,
    targets: [
        .feature(interface: .wordGame, factory: .init(
            dependencies: [.domainInterface, .dependencies]
        )),
        .feature(implements: .wordGame, factory: .init(
            dependencies: [
                .feature(interface: .wordGame),
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .wordGame, factory: .init(
            dependencies: [
                .feature(implements: .wordGame),
                .dependencies,
            ]
        )),
        .feature(example: .wordGame, factory: .init(
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:]
                ]
            ]),
            resources: ["Example/Resources/**"],
            dependencies: [
                .feature(interface: .wordGame),
                .feature(implements: .wordGame),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureWordGameExample",
            buildAction: .buildAction(targets: [.target("FeatureWordGameExample")]),
            runAction: .runAction(executable: .target("FeatureWordGameExample"))
        )
    ]
)
