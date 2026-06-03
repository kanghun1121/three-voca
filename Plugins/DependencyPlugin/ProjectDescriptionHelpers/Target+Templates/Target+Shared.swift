import ProjectDescription

public extension Target {
    /// Shared 레이어 aggregator
    static func shared(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Shared.name
        f.sources = nil
        return make(factory: f)
    }

    /// Shared 서브모듈 구현 타겟
    static func shared(implements module: ModulePath.Shared, factory: TargetFactory) -> Self {
        var f = factory
        f.name = module.rawValue
        return make(factory: f)
    }
}
