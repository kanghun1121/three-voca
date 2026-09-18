import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 인증 토큰 접근을 추상화한 저수준 포트. TokenRefreshInterceptor가 사용하며,
/// 실제 구현(AuthSessionRepository 브릿지)은 Data 모듈에 위치한다.
@DependencyClient
public struct TokenProvider: Sendable {
    public var getAccessToken: @Sendable () async -> String?
    public var refreshAccessToken: @Sendable () async -> Bool = { false }
}

extension TokenProvider: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var tokenProvider: TokenProvider {
        get { self[TokenProvider.self] }
        set { self[TokenProvider.self] = newValue }
    }
}
