import Dependencies

/// `@DependencyClient`의 기본 클로저가 unimplemented인 타입을 위한 기본 구현.
/// 상태를 가진 타입은 `testValue`와 `previewValue`를 직접 구현하여
/// 기본 인스턴스가 조용히 실제 동작을 수행하지 않도록 한다.
public protocol UnimplementedTestDependencyKey: TestDependencyKey, Sendable where Value == Self {
    init()
}

extension UnimplementedTestDependencyKey {
    public static var testValue: Self { Self() }
    public static var previewValue: Self { Self() }
}
