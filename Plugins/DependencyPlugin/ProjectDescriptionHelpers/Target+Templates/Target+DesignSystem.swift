import ProjectDescription

public extension Target {
    /// DesignSystem 모듈 타겟
    static func designSystem(factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DesignSystem"
        f.sources = .sources
        return make(factory: f)
    }
}
