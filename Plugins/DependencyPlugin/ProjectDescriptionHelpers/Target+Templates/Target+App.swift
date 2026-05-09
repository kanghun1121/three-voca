import ProjectDescription

public extension Target {
    static func app(factory: TargetFactory) -> Self {
        var f = factory
        f.product = .app
        f.name = env.appName
        f.bundleId = env.bundleIDPrefix
        return make(factory: f)
    }
}
