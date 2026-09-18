import Foundation

import Core

import Dependencies
import DependenciesMacros

/// Keychain에 저장되는 refreshToken을 `.refreshToken` 키로 고정해 감싸는 얇은 계층. Auth
/// 도메인 코드가 `Core.KeychainKey`라는 세부사항을 직접 알 필요 없게 봉쇄하는 게 목적이다.
@DependencyClient
struct AuthLocalDataSource: Sendable {
    var loadRefreshToken: @Sendable () throws -> String
    var saveRefreshToken: @Sendable (_ token: String) throws -> Void
    var deleteRefreshToken: @Sendable () throws -> Void
}

extension AuthLocalDataSource: DependencyKey {
    static let liveValue = AuthLocalDataSource(
        loadRefreshToken: {
            @Dependency(\.keychainClient) var keychain
            return try keychain.load(.refreshToken)
        },
        saveRefreshToken: { token in
            @Dependency(\.keychainClient) var keychain
            try keychain.save(.refreshToken, token)
        },
        deleteRefreshToken: {
            @Dependency(\.keychainClient) var keychain
            try keychain.delete(.refreshToken)
        }
    )
}

extension AuthLocalDataSource: UnimplementedTestDependencyKey {}


extension DependencyValues {
    var authLocalDataSource: AuthLocalDataSource {
        get { self[AuthLocalDataSource.self] }
        set { self[AuthLocalDataSource.self] = newValue }
    }
}
