import Foundation

import Dependencies

/// 저장된 refresh token 존재 여부로 로그인 상태를 판별하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct CheckAuthSessionUseCase: Sendable {
    public var execute: @Sendable () -> Bool

    public init(execute: @escaping @Sendable () -> Bool) {
        self.execute = execute
    }
}

extension CheckAuthSessionUseCase: TestDependencyKey {
    public static let testValue = CheckAuthSessionUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = CheckAuthSessionUseCase(
        execute: { true }
    )
}

public extension DependencyValues {
    var checkAuthSessionUseCase: CheckAuthSessionUseCase {
        get { self[CheckAuthSessionUseCase.self] }
        set { self[CheckAuthSessionUseCase.self] = newValue }
    }
}
