#if DEV_ENVIRONMENT
import Foundation

import Core

import Dependencies
import DependenciesMacros

@DependencyClient
public struct SignInWithDevTestAccountUseCase: Sendable {
    public var execute: @Sendable () async throws -> Void
}

extension SignInWithDevTestAccountUseCase: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var signInWithDevTestAccountUseCase: SignInWithDevTestAccountUseCase {
        get { self[SignInWithDevTestAccountUseCase.self] }
        set { self[SignInWithDevTestAccountUseCase.self] = newValue }
    }
}
#endif
