import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: env.appName,
    targets: [
        .app(factory: .init(
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:]
                ],
                "DEV_TEST_EMAIL": "$(DEV_TEST_EMAIL)",
                "DEV_TEST_PASSWORD": "$(DEV_TEST_PASSWORD)",
                "SUPABASE_URL": "$(SUPABASE_URL)",
                "SUPABASE_ANON_KEY": "$(SUPABASE_ANON_KEY)",
                "MW_DICTIONARY_API_KEY": "$(MW_DICTIONARY_API_KEY)",
                "ITSAppUsesNonExemptEncryption": false,
                "PRIVACY_POLICY_URL": "https://maize-erica-237.notion.site/387a1c6f6ce080ba927ef413ffe4cfd4"
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "FiveVoca.entitlements"),
            dependencies: [.feature, .domain, .data, .networking, .core, .designSystem],
            settings: .settings(
                base: [
                    "SUPABASE_URL": "$(SUPABASE_PROD_URL)",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "DEV_TEST_EMAIL": "",
                    "DEV_TEST_PASSWORD": ""
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
                    .debug(name: "Dev", settings: [
                        "PRODUCT_BUNDLE_IDENTIFIER": "\(env.bundleIDPrefix).dev",
                        "MARKETING_VERSION": "1.0.0",
                        "CURRENT_PROJECT_VERSION": "1",
                        "CODE_SIGN_STYLE": "Automatic",
                        "DEVELOPMENT_TEAM": "W35T2QAC67",
                        "DEV_TEST_EMAIL": "$(DEV_ACCOUNT_EMAIL)",
                        "DEV_TEST_PASSWORD": "$(DEV_ACCOUNT_PASSWORD)",
                        "SUPABASE_URL": "$(SUPABASE_DEV_URL)",
                        "SUPABASE_ANON_KEY": "$(SUPABASE_DEV_ANON_KEY)",
                        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIconDev"
                    ], xcconfig: "Secrets.xcconfig"),
                    .release(name: "Release", settings: [
                        "CODE_SIGN_STYLE": "Automatic",
                        "DEVELOPMENT_TEAM": "W35T2QAC67",
                    ], xcconfig: "Secrets.xcconfig")
                ]
            )
        ))
    ],
    schemes: [
        .scheme(
            name: "threevoca-dev",
            buildAction: .buildAction(targets: [.target(env.appName)]),
            runAction: .runAction(configuration: "Dev"),
            archiveAction: .archiveAction(configuration: "Dev"),
            profileAction: .profileAction(configuration: "Dev"),
            analyzeAction: .analyzeAction(configuration: "Dev")
        ),
        .scheme(
            name: "threevoca-prod",
            buildAction: .buildAction(targets: [.target(env.appName)]),
            runAction: .runAction(configuration: .release),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .release)
        )
    ],
    options: .options(automaticSchemesOptions: .disabled)
)
