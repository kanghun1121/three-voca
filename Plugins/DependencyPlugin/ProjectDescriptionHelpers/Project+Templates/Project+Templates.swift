import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        targets: [Target],
        schemes: [Scheme] = [],
        resourceSynthesizers: [ResourceSynthesizer] = .default
    ) -> Project {
        return Project(
            name: name,
            organizationName: env.organizationName,
            settings: .settings(
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ]
            ),
            targets: targets,
            schemes: schemes,
            resourceSynthesizers: resourceSynthesizers
        )
    }
}
