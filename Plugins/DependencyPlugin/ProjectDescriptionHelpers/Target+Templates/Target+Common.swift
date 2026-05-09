import ProjectDescription

public extension Target {
    static func make(factory: TargetFactory) -> Self {
        return .target(
            name: factory.name,
            destinations: factory.destinations,
            product: factory.product,
            productName: factory.productName,
            bundleId: factory.bundleId ?? "\(env.bundleIDPrefix).\(factory.name.lowercased())",
            deploymentTargets: factory.deploymentTargets,
            infoPlist: factory.infoPlist,
            sources: factory.sources,
            resources: factory.resources,
            entitlements: factory.entitlements,
            scripts: factory.scripts,
            dependencies: factory.dependencies,
            settings: factory.settings,
            coreDataModels: factory.coreDataModels,
            environmentVariables: factory.environmentVariables,
            launchArguments: factory.launchArguments,
            additionalFiles: factory.additionalFiles
        )
    }
}
