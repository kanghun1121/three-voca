import ProjectDescription
import DependencyPlugin

let project = Project.makeModule(
    name: "Domain",
    targets: [
        .domain(interface: .init(
            dependencies: [.dependencies]
        )),
        .domain(implements: .init(
            dependencies: [
                .domainInterface,
                .core,
                .dependencies,
            ]
        )),
        .domain(example: .init(
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
            dependencies: [
                .domain,
                .domainInterface,
                .dependencies,
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "../App/Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "../App/Secrets.xcconfig")
                ]
            )
        )),
    ],
    schemes: [
        .scheme(
            name: "DomainExample",
            buildAction: .buildAction(targets: [.target("DomainExample")]),
            runAction: .runAction(executable: .target("DomainExample"))
        )
    ]
)
