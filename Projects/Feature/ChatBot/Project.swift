import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.chatBot.rawValue,
    targets: [
        .feature(implements: .chatBot, factory: .init(
            dependencies: [
                .domainInterface,
                .dependencies,
                .designSystem,
                .core,
            ]
        )),
        .feature(tests: .chatBot, factory: .init(
            dependencies: [
                .feature(implements: .chatBot),
                .dependencies,
            ]
        )),
        .feature(example: .chatBot, factory: .init(
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
                .feature(implements: .chatBot),
                .domainInterface,
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureChatBotExample",
            buildAction: .buildAction(targets: [.target("FeatureChatBotExample")]),
            runAction: .runAction(executable: .target("FeatureChatBotExample"))
        )
    ]
)
