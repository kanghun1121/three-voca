import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.vocabulary.rawValue,
    targets: [
        .feature(implements: .vocabulary, factory: .init(
            dependencies: [
                .feature(implements: .analysis),
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .vocabulary, factory: .init(
            dependencies: [
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
                .feature(implements: .vocabulary),
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
