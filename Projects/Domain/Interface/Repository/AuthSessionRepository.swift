import Foundation

import Dependencies

/// 인증 세션 상태(access/refresh token, 인증 상태 스트림)를 관리하는 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct AuthSessionRepository: Sendable {
    public var getAccessToken: @Sendable () async -> String?
    public var setAccessToken: @Sendable (String) async -> Void
    public var getRefreshToken: @Sendable () throws -> String
    public var setRefreshToken: @Sendable (String) throws -> Void
    public var clearSession: @Sendable () async throws -> Void
    public var deleteAccount: @Sendable () async throws -> Void
    public var refreshAccessToken: @Sendable () async -> Bool
    public var authStateStream: @Sendable () -> AsyncStream<AuthState>

    public init(
        getAccessToken: @escaping @Sendable () async -> String?,
        setAccessToken: @escaping @Sendable (String) async -> Void,
        getRefreshToken: @escaping @Sendable () throws -> String,
        setRefreshToken: @escaping @Sendable (String) throws -> Void,
        clearSession: @escaping @Sendable () async throws -> Void,
        deleteAccount: @escaping @Sendable () async throws -> Void,
        refreshAccessToken: @escaping @Sendable () async -> Bool,
        authStateStream: @escaping @Sendable () -> AsyncStream<AuthState>
    ) {
        self.getAccessToken = getAccessToken
        self.setAccessToken = setAccessToken
        self.getRefreshToken = getRefreshToken
        self.setRefreshToken = setRefreshToken
        self.clearSession = clearSession
        self.deleteAccount = deleteAccount
        self.refreshAccessToken = refreshAccessToken
        self.authStateStream = authStateStream
    }
}

extension AuthSessionRepository: TestDependencyKey {
    public static let testValue = AuthSessionRepository(
        getAccessToken: unimplemented("\(Self.self).getAccessToken"),
        setAccessToken: unimplemented("\(Self.self).setAccessToken"),
        getRefreshToken: unimplemented("\(Self.self).getRefreshToken"),
        setRefreshToken: unimplemented("\(Self.self).setRefreshToken"),
        clearSession: unimplemented("\(Self.self).clearSession"),
        deleteAccount: unimplemented("\(Self.self).deleteAccount"),
        refreshAccessToken: unimplemented("\(Self.self).refreshAccessToken"),
        authStateStream: unimplemented("\(Self.self).authStateStream")
    )
}

public extension DependencyValues {
    var authSessionRepository: AuthSessionRepository {
        get { self[AuthSessionRepository.self] }
        set { self[AuthSessionRepository.self] = newValue }
    }
}
