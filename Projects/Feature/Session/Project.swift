import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.session.rawValue,
    targets: [
        .feature(interface: .session, factory: .init(
            dependencies: [.domainInterface]
        )),
        .feature(implements: .session, factory: .init(
            dependencies: [
                .feature(interface: .session),
                .feature(interface: .vocabulary),
                .feature(implements: .vocabulary),
                .feature(implements: .wordGame),
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .session, factory: .init(
            dependencies: [
                .feature(implements: .session),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .session, factory: .init(
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
                .feature(interface: .session),
                .feature(implements: .session),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureSessionExample",
            buildAction: .buildAction(targets: [.target("FeatureSessionExample")]),
            runAction: .runAction(executable: .target("FeatureSessionExample"))
        )
    ]
)
