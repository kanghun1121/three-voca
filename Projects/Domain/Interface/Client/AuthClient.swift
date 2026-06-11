import Foundation

import Dependencies

public struct AuthClient: Sendable {
    public var signInWithApple: @Sendable (String) async throws -> AuthToken

    public init(signInWithApple: @escaping @Sendable (String) async throws -> AuthToken) {
        self.signInWithApple = signInWithApple
    }
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient(
        signInWithApple: unimplemented("\(Self.self).signInWithApple")
    )

    public static let previewValue = AuthClient(
        signInWithApple: { _ in .previewFixture }
    )
}

public extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
