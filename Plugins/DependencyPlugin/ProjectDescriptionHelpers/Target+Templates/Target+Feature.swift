import ProjectDescription

public extension Target {
    // Feature 레이어 aggregator
    static func feature(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Feature.name
        f.sources = nil
        return make(factory: f)
    }

    // Interface
    static func feature(interface module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Interface"
        f.sources = .interface
        return make(factory: f)
    }

    // Implements
    static func feature(implements module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)"
        f.sources = .sources
        return make(factory: f)
    }

    // Testing
    static func feature(testing module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Testing"
        f.sources = .testing
        return make(factory: f)
    }

    // Tests
    static func feature(tests module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Tests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }

    // Example
    static func feature(example module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Example"
        f.sources = .exampleSources
        f.product = .app
        return make(factory: f)
    }
}
