import Foundation

import Dependencies

/// 앱 시작 시 access token을 갱신 시도하는 UseCase(결과는 무시하고 상태 스트림으로만 반영된다). ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct RefreshAuthSessionUseCase: Sendable {
    public var execute: @Sendable () async -> Void

    public init(execute: @escaping @Sendable () async -> Void) {
        self.execute = execute
    }
}

extension RefreshAuthSessionUseCase: TestDependencyKey {
    public static let testValue = RefreshAuthSessionUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = RefreshAuthSessionUseCase(
        execute: {}
    )
}

public extension DependencyValues {
    var refreshAuthSessionUseCase: RefreshAuthSessionUseCase {
        get { self[RefreshAuthSessionUseCase.self] }
        set { self[RefreshAuthSessionUseCase.self] = newValue }
    }
}
