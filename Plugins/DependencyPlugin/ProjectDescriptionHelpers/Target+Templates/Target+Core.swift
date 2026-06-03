import ProjectDescription

public extension Target {
    /// Core 레이어 aggregator
    static func core(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Core.name
        f.sources = .sources
        return make(factory: f)
    }


}
