import Foundation

import Dependencies

public struct AuthClient: Sendable {
    public var signInWithApple: @Sendable (String) async throws -> AuthToken
    public var checkSession: @Sendable () async -> Void

    public init(
        signInWithApple: @escaping @Sendable (String) async throws -> AuthToken,
        checkSession: @escaping @Sendable () async -> Void
    ) {
        self.signInWithApple = signInWithApple
        self.checkSession = checkSession
    }
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient(
        signInWithApple: unimplemented("\(Self.self).signInWithApple"),
        checkSession: unimplemented("\(Self.self).checkSession")
    )

    public static let previewValue = AuthClient(
        signInWithApple: { _ in .previewFixture },
        checkSession: {}
    )
}

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
