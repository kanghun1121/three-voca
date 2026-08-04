import ProjectDescription

public extension Target {
    /// Interface 타겟 — Client struct, Repository struct, UseCase struct, DependencyKey, Model
    static func useCase(interface factory: TargetFactory) -> Self {
        var f = factory
        f.name = "UseCaseInterface"
        f.sources = .interface
        return make(factory: f)
    }

    /// Implements 타겟 — liveValue, DTO, Mapping
    static func useCase(implements factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.UseCase.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func useCase(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "UseCaseTests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }

    /// Example 타겟 — 독립 실행 앱. 실제 네트워크 호출 확인용
    static func useCase(example factory: TargetFactory) -> Self {
        var f = factory
        f.name = "UseCaseExample"
        f.sources = .exampleSources
        f.product = .app
        return make(factory: f)
    }
}
