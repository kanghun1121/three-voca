import ProjectDescription

public struct ProjectEnvironment {
    public let appName: String
    public let organizationName: String
    public let bundleIDPrefix: String
    public let deploymentTargets: DeploymentTargets
    public let destinations: Destinations
}

public let env = ProjectEnvironment(
    appName: "FiveVoca",
    organizationName: "FiveVoca",
    bundleIDPrefix: "com.kangdev.FiveVoca",
    deploymentTargets: .iOS("16.0"),
    destinations: .iOS
)
