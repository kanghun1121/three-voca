import Foundation

import Dependencies

public struct AuthSessionClient: Sendable {
    public var getAccessToken: @Sendable () async -> String?
    public var setAccessToken: @Sendable (String) async -> Void
    public var getRefreshToken: @Sendable () throws -> String
    public var setRefreshToken: @Sendable (String) throws -> Void
    public var clearSession: @Sendable () async throws -> Void
    public var authStateStream: @Sendable () -> AsyncStream<AuthState>

    public init(
        getAccessToken: @escaping @Sendable () async -> String?,
        setAccessToken: @escaping @Sendable (String) async -> Void,
        getRefreshToken: @escaping @Sendable () throws -> String,
        setRefreshToken: @escaping @Sendable (String) throws -> Void,
        clearSession: @escaping @Sendable () async throws -> Void,
        authStateStream: @escaping @Sendable () -> AsyncStream<AuthState>
    ) {
        self.getAccessToken = getAccessToken
        self.setAccessToken = setAccessToken
        self.getRefreshToken = getRefreshToken
        self.setRefreshToken = setRefreshToken
        self.clearSession = clearSession
        self.authStateStream = authStateStream
    }
}

extension AuthSessionClient: TestDependencyKey {
    public static let testValue = AuthSessionClient(
        getAccessToken: unimplemented("\(Self.self).getAccessToken"),
        setAccessToken: unimplemented("\(Self.self).setAccessToken"),
        getRefreshToken: unimplemented("\(Self.self).getRefreshToken"),
        setRefreshToken: unimplemented("\(Self.self).setRefreshToken"),
        clearSession: unimplemented("\(Self.self).clearSession"),
        authStateStream: unimplemented("\(Self.self).authStateStream")
    )

    public static let previewValue = AuthSessionClient(
        getAccessToken: { AuthToken.previewFixture.accessToken },
        setAccessToken: { _ in },
        getRefreshToken: { AuthToken.previewFixture.refreshToken },
        setRefreshToken: { _ in },
        clearSession: {},
        authStateStream: { AsyncStream { _ in } }
    )
}

public extension DependencyValues {
    var authSessionClient: AuthSessionClient {
        get { self[AuthSessionClient.self] }
        set { self[AuthSessionClient.self] = newValue }
    }
}
