import ProjectDescription

let workspace = Workspace(
    name: "FiveVoca",
    projects: ["Projects/**"],
    schemes: [
        .scheme(
            name: "AllTest",
            buildAction: .buildAction(targets: [
                .project(path: "Projects/Core", target: "CoreTests"),
                .project(path: "Projects/Domain", target: "DomainTests"),
                .project(path: "Projects/Networking", target: "NetworkingTests"),
                .project(path: "Projects/Feature/Home", target: "FeatureHomeTests"),
                .project(path: "Projects/Feature/Session", target: "FeatureSessionTests"),
                .project(path: "Projects/Feature/Vocabulary", target: "FeatureVocabularyTests"),
                .project(path: "Projects/Feature/WordGame", target: "FeatureWordGameTests"),
            ]),
            testAction: .targets([
                .testableTarget(
                    target: .project(path: "Projects/Core", target: "CoreTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Domain", target: "DomainTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Networking", target: "NetworkingTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Feature/Home", target: "FeatureHomeTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Feature/Session", target: "FeatureSessionTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Feature/Vocabulary", target: "FeatureVocabularyTests")
                ),
                .testableTarget(
                    target: .project(path: "Projects/Feature/WordGame", target: "FeatureWordGameTests")
                ),
            ])
        )
    ]
)
