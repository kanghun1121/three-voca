import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.analysis.rawValue,
    targets: [
        .feature(implements: .analysis, factory: .init(
            dependencies: [
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .analysis, factory: .init(
            dependencies: [
                .feature(implements: .analysis),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .analysis, factory: .init(
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
                .feature(implements: .analysis),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureAnalysisExample",
            buildAction: .buildAction(targets: [.target("FeatureAnalysisExample")]),
            runAction: .runAction(executable: .target("FeatureAnalysisExample"))
        )
    ]
)
