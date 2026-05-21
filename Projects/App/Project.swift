import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: env.appName,
    targets: [
        .app(factory: .init(
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "1.0",
                "CFBundleVersion": "1",
                "UILaunchScreen": [
                    "UIColorName": "",
                    "UIImageName": ""
                ],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:]
                ],
                "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)"
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [.feature, .domain],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "Secrets.xcconfig")
                ]
            )
        ))
    ]
)
