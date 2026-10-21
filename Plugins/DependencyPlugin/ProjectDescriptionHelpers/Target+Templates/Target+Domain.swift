import ProjectDescription

public extension Target {
    /// Interface 타겟 — Client struct, DependencyKey, Model
    static func domain(interface factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DomainInterface"
        f.sources = .interface
        return make(factory: f)
    }

    /// Implements 타겟 — liveValue, DTO, Mapping
    static func domain(implements factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Domain.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func domain(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DomainTests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }

    /// Example 타겟 — 독립 실행 앱. 실제 네트워크 호출 확인용
    static func domain(example factory: TargetFactory) -> Self {
        var f = factory
        f.name = "DomainExample"
        f.sources = .exampleSources
        f.product = .app
        return make(factory: f)
    }
}
