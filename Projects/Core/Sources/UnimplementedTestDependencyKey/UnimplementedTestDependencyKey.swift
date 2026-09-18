import Dependencies

/// `@DependencyClient`로 모든 프로퍼티가 unimplemented 기본값을 갖는 타입을 위한
/// `TestDependencyKey` 기본 구현. `Self()`가 이미 "모든 클로저가 개별적으로
/// unimplemented인 인스턴스"이므로 testValue/previewValue를 매번 손으로 쓸 필요가 없다.
public protocol UnimplementedTestDependencyKey: TestDependencyKey, Sendable where Value == Self {
    init()
}

extension UnimplementedTestDependencyKey {
    public static var testValue: Self { Self() }
    public static var previewValue: Self { Self() }
}
