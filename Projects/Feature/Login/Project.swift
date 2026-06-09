import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.login.rawValue,
    targets: [
        .feature(interface: .login, factory: .init()),
        .feature(implements: .login, factory: .init(
            dependencies: [
                .feature(interface: .login),
                .designSystem,
            ]
        )),
        .feature(tests: .login, factory: .init(
            dependencies: [
                .feature(implements: .login),
            ]
        )),
        .feature(example: .login, factory: .init(
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
                .feature(interface: .login),
                .feature(implements: .login),
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureLoginExample",
            buildAction: .buildAction(targets: [.target("FeatureLoginExample")]),
            runAction: .runAction(executable: .target("FeatureLoginExample"))
        )
    ]
)
