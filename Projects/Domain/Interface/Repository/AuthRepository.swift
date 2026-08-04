import Foundation

import Dependencies

/// 인증/회원가입 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct AuthRepository: Sendable {
    public var signInWithApple: @Sendable (_ identityToken: String) async throws -> AuthToken

    public init(signInWithApple: @escaping @Sendable (_ identityToken: String) async throws -> AuthToken) {
        self.signInWithApple = signInWithApple
    }
}

extension AuthRepository: TestDependencyKey {
    public static let testValue = AuthRepository(
        signInWithApple: unimplemented("\(Self.self).signInWithApple")
    )
}

public extension DependencyValues {
    var authRepository: AuthRepository {
        get { self[AuthRepository.self] }
        set { self[AuthRepository.self] = newValue }
    }
}
