import ProjectDescription

public extension Target {
    // Shared 레이어 aggregator
    static func shared(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Shared.name
        f.sources = nil
        return make(factory: f)
    }
}
