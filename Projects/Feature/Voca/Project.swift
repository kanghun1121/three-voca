import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.Voca.rawValue,
    targets: [
        .feature(interface: .Voca, factory: .init(
            dependencies: [.domainInterface]
        )),
        .feature(implements: .Voca, factory: .init(
            dependencies: [
                .feature(interface: .Voca),
                .dependencies,
                .designSystem,
            ]
        )),
        .feature(testing: .Voca, factory: .init(
            dependencies: [.feature(interface: .Voca)]
        )),
        .feature(tests: .Voca, factory: .init(
            dependencies: [
                .feature(testing: .Voca),
                .feature(implements: .Voca),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .Voca, factory: .init(
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
                .feature(interface: .Voca),
                .feature(implements: .Voca),
                .feature(testing: .Voca),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureVocaExample",
            buildAction: .buildAction(targets: [.target("FeatureVocaExample")]),
            runAction: .runAction(executable: .target("FeatureVocaExample"))
        )
    ]
)
