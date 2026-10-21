import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 인증 세션 상태(access/refresh token, 인증 상태 스트림)를 관리하는 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct AuthSessionRepository: Sendable {
    public var getAccessToken: @Sendable () async -> String?
    public var setAccessToken: @Sendable (String) async -> Void
    public var getRefreshToken: @Sendable () throws -> String
    public var setRefreshToken: @Sendable (String) throws -> Void
    public var clear: @Sendable () async throws -> Void
    public var deleteAccount: @Sendable () async throws -> Void
    public var refreshAccessToken: @Sendable () async -> Bool = { false }
    public var stateStream: @Sendable () -> AsyncStream<AuthState> = { AsyncStream { $0.finish() } }
}

extension AuthSessionRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var authSessionRepository: AuthSessionRepository {
        get { self[AuthSessionRepository.self] }
        set { self[AuthSessionRepository.self] = newValue }
    }
}
