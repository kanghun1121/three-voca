import Foundation

import Dependencies

/// 로그아웃을 수행하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct LogoutUseCase: Sendable {
    public var execute: @Sendable () async throws -> Void

    public init(execute: @escaping @Sendable () async throws -> Void) {
        self.execute = execute
    }
}

extension LogoutUseCase: TestDependencyKey {
    public static let testValue = LogoutUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = LogoutUseCase(
        execute: {}
    )
}

public extension DependencyValues {
    var logoutUseCase: LogoutUseCase {
        get { self[LogoutUseCase.self] }
        set { self[LogoutUseCase.self] = newValue }
    }
}
