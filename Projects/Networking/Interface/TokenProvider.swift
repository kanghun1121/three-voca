import Foundation

import Dependencies

/// 인증 토큰 접근을 추상화한 저수준 포트. TokenRefreshInterceptor가 사용하며,
/// 실제 구현(AuthSessionRepository 브릿지)은 Data 모듈에 위치한다.
public struct TokenProvider: Sendable {
    public var getAccessToken: @Sendable () async -> String?
    public var refreshAccessToken: @Sendable () async -> Bool

    public init(
        getAccessToken: @escaping @Sendable () async -> String?,
        refreshAccessToken: @escaping @Sendable () async -> Bool
    ) {
        self.getAccessToken = getAccessToken
        self.refreshAccessToken = refreshAccessToken
    }
}

extension TokenProvider: TestDependencyKey {
    public static let testValue = TokenProvider(
        getAccessToken: unimplemented("\(Self.self).getAccessToken", placeholder: nil),
        refreshAccessToken: unimplemented("\(Self.self).refreshAccessToken", placeholder: false)
    )
}

public extension DependencyValues {
    var tokenProvider: TokenProvider {
        get { self[TokenProvider.self] }
        set { self[TokenProvider.self] = newValue }
    }
}
