import ProjectDescription

let workspace = Workspace(
    name: "FiveVoca",
    projects: ["Projects/**"],
    schemes: [
        .scheme(
            name: "AllTest",
            buildAction: .buildAction(targets: [
                .project(path: "Projects/Feature/Home", target: "FeatureHomeTests"),
                .project(path: "Projects/Feature/Session", target: "FeatureSessionTests"),
            ]),
            testAction: .targets([
                .testableTarget(
                    target: .project(path: "Projects/Feature/Home", target: "FeatureHomeTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Feature/Session", target: "FeatureSessionTests")
                ),
            ])
        )
    ]
)
