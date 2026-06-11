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
                "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)",
                "MW_DICTIONARY_API_KEY": "$(MW_DICTIONARY_API_KEY)",
                "UIAppFonts": [
                    "Pretendard-Thin.otf",
                    "Pretendard-ExtraLight.otf",
                    "Pretendard-Light.otf",
                    "Pretendard-Regular.otf",
                    "Pretendard-Medium.otf",
                    "Pretendard-SemiBold.otf",
                    "Pretendard-Bold.otf",
                    "Pretendard-ExtraBold.otf",
                    "Pretendard-Black.otf"
                ]
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .dictionary([
                "com.apple.developer.applesignin": ["Default"],
            ]),
            dependencies: [.feature, .domain, .designSystem],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "Secrets.xcconfig")
                ]
            )
        ))
    ]
)
