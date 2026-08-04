import ProjectDescription

public extension Target {
    /// Data 레이어 — Repository의 liveValue(실제 구현) 구현체
    static func data(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Data.name
        f.sources = .sources
        return make(factory: f)
    }
}
