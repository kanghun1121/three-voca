import ProjectDescription

public extension Target {
    /// Feature 레이어 aggregator
    static func feature(factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Feature.name
        f.sources = nil
        return make(factory: f)
    }

    /// Interface 타겟 — 외부 Feature가 참조하는 공개 계약
    static func feature(interface module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Interface"
        f.sources = .interface
        return make(factory: f)
    }

    /// Implements 타겟 — 실제 View, ViewModel 구현
    static func feature(implements module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)"
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func feature(tests module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Tests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }

    /// Example 타겟 — 독립 실행 앱. 격리 확인용
    static func feature(example module: ModulePath.Feature, factory: TargetFactory) -> Self {
        var f = factory
        f.name = "Feature\(module.rawValue)Example"
        f.sources = .exampleSources
        f.product = .app
        return make(factory: f)
    }
}
