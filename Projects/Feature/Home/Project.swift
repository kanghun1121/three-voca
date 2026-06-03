import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.home.rawValue,
    targets: [
        .feature(interface: .home, factory: .init(
            dependencies: [.domainInterface]
        )),
        .feature(implements: .home, factory: .init(
            dependencies: [
                .feature(interface: .home),
                .feature(interface: .session),
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(testing: .home, factory: .init(
            resources: ["Testing/Resources/**"],
            dependencies: [.feature(interface: .home)]
        )),
        .feature(tests: .home, factory: .init(
            dependencies: [
                .feature(testing: .home),
                .feature(implements: .home),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .home, factory: .init(
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
                .feature(interface: .home),
                .feature(implements: .home),
                .feature(testing: .home),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureHomeExample",
            buildAction: .buildAction(targets: [.target("FeatureHomeExample")]),
            runAction: .runAction(executable: .target("FeatureHomeExample"))
        )
    ]
)
