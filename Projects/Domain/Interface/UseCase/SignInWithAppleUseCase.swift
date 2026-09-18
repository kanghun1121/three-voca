import Foundation

import Core

import Dependencies
import DependenciesMacros

/// Apple 로그인을 수행하고 세션을 저장하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
@DependencyClient
public struct SignInWithAppleUseCase: Sendable {
    public var execute: @Sendable (_ identityToken: String) async throws -> AuthToken
}

extension SignInWithAppleUseCase: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var signInWithAppleUseCase: SignInWithAppleUseCase {
        get { self[SignInWithAppleUseCase.self] }
        set { self[SignInWithAppleUseCase.self] = newValue }
    }
}
