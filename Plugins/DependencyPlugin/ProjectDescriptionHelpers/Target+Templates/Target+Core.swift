import ProjectDescription

public extension Target {
    /// Core 레이어 aggregator
    static func core(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Core.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func core(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "CoreTests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }
}
