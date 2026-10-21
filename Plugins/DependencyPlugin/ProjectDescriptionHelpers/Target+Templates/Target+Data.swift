import ProjectDescription

public extension Target {
    /// Data 레이어 — Repository의 liveValue(실제 구현) 구현체
    static func data(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Data.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func data(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DataTests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }
}
