#if DEV_ENVIRONMENT
import Foundation

import Core

import Dependencies
import DependenciesMacros

@DependencyClient
public struct DevTestAccountRepository: Sendable {
    public var signIn: @Sendable () async throws -> AuthToken
}

extension DevTestAccountRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var devTestAccountRepository: DevTestAccountRepository {
        get { self[DevTestAccountRepository.self] }
        set { self[DevTestAccountRepository.self] = newValue }
    }
}
#endif
