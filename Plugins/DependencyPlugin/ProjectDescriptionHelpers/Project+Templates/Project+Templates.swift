import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        targets: [Target],
        schemes: [Scheme] = [],
        options: Project.Options = .options(),
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        return Project(
            name: name,
            organizationName: env.organizationName,
            options: options,
            settings: .settings(
                configurations: [
                    .debug(name: "Debug"),
                    .debug(name: "Dev", settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG DEV_ENVIRONMENT"
                    ]),
                    .release(name: "Release")
                ]
            ),
            targets: targets,
            schemes: schemes,
            resourceSynthesizers: resourceSynthesizers
        )
    }
}
