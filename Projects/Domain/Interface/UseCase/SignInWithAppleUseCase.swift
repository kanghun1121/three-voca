import Foundation

import Dependencies

/// Apple 로그인을 수행하고 세션을 저장하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct SignInWithAppleUseCase: Sendable {
    public var execute: @Sendable (_ identityToken: String) async throws -> AuthToken

    public init(execute: @escaping @Sendable (_ identityToken: String) async throws -> AuthToken) {
        self.execute = execute
    }
}

extension SignInWithAppleUseCase: TestDependencyKey {
    public static let testValue = SignInWithAppleUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = SignInWithAppleUseCase(
        execute: { _ in .previewFixture }
    )
}

public extension DependencyValues {
    var signInWithAppleUseCase: SignInWithAppleUseCase {
        get { self[SignInWithAppleUseCase.self] }
        set { self[SignInWithAppleUseCase.self] = newValue }
    }
}
