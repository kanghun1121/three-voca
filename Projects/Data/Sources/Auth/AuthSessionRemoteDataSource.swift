import Foundation

import NetworkingInterface

import Dependencies

/// 로그인된 세션의 갱신/삭제만 담당(로그인 자체는 `AuthRemoteDataSource`).
struct AuthSessionRemoteDataSource: Sendable {
    var refreshToken: @Sendable (_ refreshToken: String) async throws -> AuthTokenResponseDTO
    var deleteAccount: @Sendable (_ accessToken: String) async throws -> Void
}

extension AuthSessionRemoteDataSource: DependencyKey {
    static let liveValue = AuthSessionRemoteDataSource(
        refreshToken: { refreshToken in
            @Dependency(\.httpClient) var httpClient
            return try await httpClient.request(RefreshTokenRequest(refreshToken: refreshToken))
        },
        deleteAccount: { accessToken in
            @Dependency(\.httpClient) var httpClient
            try await httpClient.request(DeleteAccountRequest(accessToken: accessToken))
        }
    )
}

extension AuthSessionRemoteDataSource: TestDependencyKey {
    static let testValue = AuthSessionRemoteDataSource(
        refreshToken: unimplemented("\(Self.self).refreshToken"),
        deleteAccount: unimplemented("\(Self.self).deleteAccount")
    )
}

extension DependencyValues {
    var authSessionRemoteDataSource: AuthSessionRemoteDataSource {
        get { self[AuthSessionRemoteDataSource.self] }
        set { self[AuthSessionRemoteDataSource.self] = newValue }
    }
}
