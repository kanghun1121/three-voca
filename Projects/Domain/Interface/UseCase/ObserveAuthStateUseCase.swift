import Foundation

import Dependencies

/// 인증 상태 변경을 구독하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct ObserveAuthStateUseCase: Sendable {
    public var execute: @Sendable () -> AsyncStream<AuthState>

    public init(execute: @escaping @Sendable () -> AsyncStream<AuthState>) {
        self.execute = execute
    }
}

extension ObserveAuthStateUseCase: TestDependencyKey {
    public static let testValue = ObserveAuthStateUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = ObserveAuthStateUseCase(
        execute: { AsyncStream { _ in } }
    )
}

public extension DependencyValues {
    var observeAuthStateUseCase: ObserveAuthStateUseCase {
        get { self[ObserveAuthStateUseCase.self] }
        set { self[ObserveAuthStateUseCase.self] = newValue }
    }
}
