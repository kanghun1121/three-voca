import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 인증/회원가입 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct AuthRepository: Sendable {
    public var signInWithApple: @Sendable (_ identityToken: String) async throws -> AuthToken
}

extension AuthRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var authRepository: AuthRepository {
        get { self[AuthRepository.self] }
        set { self[AuthRepository.self] = newValue }
    }
}
