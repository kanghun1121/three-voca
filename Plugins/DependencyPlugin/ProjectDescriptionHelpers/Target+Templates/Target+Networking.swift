import ProjectDescription

public extension Target {
    /// Interface 타겟 — HTTPClienting, Requestable 등 네트워크 포트
    static func networking(interface factory: TargetFactory) -> Self {
        var f = factory
        f.name = "NetworkingInterface"
        f.sources = .interface
        return make(factory: f)
    }

    /// Implements 타겟 — HTTPClient 등 실제 구현
    static func networking(implements factory: TargetFactory) -> Self {
        var f = factory
        f.name = ModulePath.Networking.name
        f.sources = .sources
        return make(factory: f)
    }

    /// Tests 타겟 — 단위 테스트. 외부에 노출 안 됨
    static func networking(tests factory: TargetFactory) -> Self {
        var f = factory
        f.name = "NetworkingTests"
        f.sources = .tests
        f.product = .unitTests
        return make(factory: f)
    }
}
