import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: ModulePath.Feature.name + ModulePath.Feature.lesson.rawValue,
    targets: [
        .feature(interface: .lesson, factory: .init(
            dependencies: [
                .dependencies,
            ]
        )),
        .feature(implements: .lesson, factory: .init(
            dependencies: [
                .feature(interface: .lesson),
                .feature(interface: .word),
                .feature(interface: .wordGame),
                .domainInterface,
                .dependencies,
                .designSystem,
                .swiftUINavigation,
            ]
        )),
        .feature(tests: .lesson, factory: .init(
            dependencies: [
                .feature(implements: .lesson),
                .domainInterface,
                .dependencies,
            ]
        )),
        .feature(example: .lesson, factory: .init(
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
                .feature(implements: .lesson),
                .dependencies,
                .designSystem,
            ]
        )),
    ],
    schemes: [
        .scheme(
            name: "FeatureLessonExample",
            buildAction: .buildAction(targets: [.target("FeatureLessonExample")]),
            runAction: .runAction(executable: .target("FeatureLessonExample"))
        )
    ]
)
