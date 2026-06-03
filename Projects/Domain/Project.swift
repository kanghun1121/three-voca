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
                ]
            ]),
            dependencies: [
                .domain,
                .domainInterface,
                .dependencies,
            ]
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
