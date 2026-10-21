import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.word.rawValue,
    targets: [
        .feature(interface: .word, factory: .init(
            dependencies: [
                .dependencies,
            ]
        )),
        .feature(implements: .word, factory: .init(
            dependencies: [
                .feature(interface: .word),
                .feature(interface: .chunkReader),
                .feature(interface: .chatBot),
                .domainInterface,
                .dependencies,
                .designSystem,
                .swiftUINavigation,
                .core,
            ]
        )),
        .feature(tests: .word, factory: .init(
            dependencies: [
                .feature(implements: .word),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .word, factory: .init(
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
                .feature(implements: .word),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureWordExample",
            buildAction: .buildAction(targets: [.target("FeatureWordExample")]),
            runAction: .runAction(executable: .target("FeatureWordExample"))
        )
    ]
)
