import Foundation

import Dependencies

public struct AuthSessionClient: Sendable {
    public var getAccessToken: @Sendable () -> String?
    public var setAccessToken: @Sendable (String) -> Void
    public var getRefreshToken: @Sendable () throws -> String
    public var setRefreshToken: @Sendable (String) throws -> Void
    public var clearSession: @Sendable () throws -> Void

    public init(
        getAccessToken: @escaping @Sendable () -> String?,
        setAccessToken: @escaping @Sendable (String) -> Void,
        getRefreshToken: @escaping @Sendable () throws -> String,
        setRefreshToken: @escaping @Sendable (String) throws -> Void,
        clearSession: @escaping @Sendable () throws -> Void
    ) {
        self.getAccessToken = getAccessToken
        self.setAccessToken = setAccessToken
        self.getRefreshToken = getRefreshToken
        self.setRefreshToken = setRefreshToken
        self.clearSession = clearSession
    }
}

extension AuthSessionClient: TestDependencyKey {
    public static let testValue = AuthSessionClient(
        getAccessToken: unimplemented("\(Self.self).getAccessToken"),
        setAccessToken: unimplemented("\(Self.self).setAccessToken"),
        getRefreshToken: unimplemented("\(Self.self).getRefreshToken"),
        setRefreshToken: unimplemented("\(Self.self).setRefreshToken"),
        clearSession: unimplemented("\(Self.self).clearSession")
    )

    public static let previewValue = AuthSessionClient(
        getAccessToken: { AuthToken.previewFixture.accessToken },
        setAccessToken: { _ in },
        getRefreshToken: { AuthToken.previewFixture.refreshToken },
        setRefreshToken: { _ in },
        clearSession: { }
    )
}

public extension DependencyValues {
    var authSessionClient: AuthSessionClient {
        get { self[AuthSessionClient.self] }
        set { self[AuthSessionClient.self] = newValue }
    }
}
