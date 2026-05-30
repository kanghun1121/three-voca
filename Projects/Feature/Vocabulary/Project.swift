import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.vocabulary.rawValue,
    targets: [
        .feature(interface: .vocabulary, factory: .init(
            dependencies: [.domainInterface]
        )),
        .feature(implements: .vocabulary, factory: .init(
            dependencies: [
                .feature(interface: .vocabulary),
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(testing: .vocabulary, factory: .init(
            dependencies: [.feature(interface: .vocabulary)]
        )),
        .feature(tests: .vocabulary, factory: .init(
            dependencies: [
                .feature(testing: .vocabulary),
                .feature(implements: .vocabulary),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .vocabulary, factory: .init(
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
                .feature(interface: .vocabulary),
                .feature(implements: .vocabulary),
                .feature(testing: .vocabulary),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureVocabularyExample",
            buildAction: .buildAction(targets: [.target("FeatureVocabularyExample")]),
            runAction: .runAction(executable: .target("FeatureVocabularyExample"))
        )
    ]
)
