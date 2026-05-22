import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.Home.rawValue,
    targets: [
        .feature(interface: .Home, factory: .init(
            dependencies: [.domainInterface]
        )),
        .feature(implements: .Home, factory: .init(
            dependencies: [
                .feature(interface: .Home),
                .dependencies,
                .designSystem,
            ]
        )),
        .feature(testing: .Home, factory: .init(
            resources: ["Testing/Resources/**"],
            dependencies: [.feature(interface: .Home)]
        )),
        .feature(tests: .Home, factory: .init(
            dependencies: [
                .feature(testing: .Home),
                .feature(implements: .Home),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .Home, factory: .init(
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
                .feature(interface: .Home),
                .feature(implements: .Home),
                .feature(testing: .Home),
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
