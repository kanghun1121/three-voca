import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.myPage.rawValue,
    targets: [
        .feature(implements: .myPage, factory: .init(
            dependencies: [
                .dependencies,
                .designSystem,
                .useCaseInterface,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .myPage, factory: .init(
            dependencies: [
                .feature(implements: .myPage),
                .dependencies,
            ]
        )),
        .feature(example: .myPage, factory: .init(
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
                .feature(implements: .myPage),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureMyPageExample",
            buildAction: .buildAction(targets: [.target("FeatureMyPageExample")]),
            runAction: .runAction(executable: .target("FeatureMyPageExample"))
        )
    ]
)
