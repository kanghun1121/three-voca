import Foundation

import Dependencies

/// 회원 탈퇴를 수행하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct DeleteAccountUseCase: Sendable {
    public var execute: @Sendable () async throws -> Void

    public init(execute: @escaping @Sendable () async throws -> Void) {
        self.execute = execute
    }
}

extension DeleteAccountUseCase: TestDependencyKey {
    public static let testValue = DeleteAccountUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = DeleteAccountUseCase(
        execute: {}
    )
}

public extension DependencyValues {
    var deleteAccountUseCase: DeleteAccountUseCase {
        get { self[DeleteAccountUseCase.self] }
        set { self[DeleteAccountUseCase.self] = newValue }
    }
}
