import ProjectDescription
import DependencyPlugin

let targets: [Target] = [
    .core(factory: .init(dependencies: [.shared])),
    .core(example: .init(
        infoPlist: .extendingDefault(with: [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UILaunchStoryboardName": "LaunchScreen",
            "UIApplicationSceneManifest": [
                "UIApplicationSupportsMultipleScenes": false,
                "UISceneConfigurations": [:]
            ],
            "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)"
        ]),
        resources: ["Example/Resources/**"],
        dependencies: [.target(name: "Core")],
        settings: .settings(
            configurations: [
                .debug(name: "Debug", xcconfig: "Example/Secrets.xcconfig"),
                .release(name: "Release", xcconfig: "Example/Secrets.xcconfig")
            ]
        )
    ))
]

let project = Project.makeModule(
    name: "Core",
    targets: targets,
    schemes: [
        .scheme(
            name: "CoreExample",
            buildAction: .buildAction(targets: [.target("CoreExample")]),
            runAction: .runAction(executable: .target("CoreExample"))
        )
    ]
)
