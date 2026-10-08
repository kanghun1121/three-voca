import Foundation

import Core
import NetworkingInterface

import Dependencies
import DependenciesMacros

/// Apple 로그인 교환 요청. 회원가입/로그인 자체(계정 생성)만 담당 — 세션 갱신/삭제는
/// `AuthSessionRemoteDataSource`의 책임이다(별개 도메인 흐름이라 나눔).
@DependencyClient
struct AuthRemoteDataSource: Sendable {
    var exchangeAppleToken: @Sendable (_ identityToken: String) async throws -> AuthTokenResponseDTO
}

extension AuthRemoteDataSource: DependencyKey {
    static let liveValue = AuthRemoteDataSource(
        exchangeAppleToken: { identityToken in
            @Dependency(\.authenticatedHTTPClient) var client
            return try await client.request(ExchangeAppleTokenRequest(identityToken: identityToken))
        }
    )
}

extension AuthRemoteDataSource: UnimplementedTestDependencyKey {}


extension DependencyValues {
    var authRemoteDataSource: AuthRemoteDataSource {
        get { self[AuthRemoteDataSource.self] }
        set { self[AuthRemoteDataSource.self] = newValue }
    }
}

#if DEV_ENVIRONMENT
extension AuthRemoteDataSource {
    func signInWithDevTestAccount() async throws -> AuthTokenResponseDTO {
        guard let email = Bundle.main.object(forInfoDictionaryKey: "DEV_TEST_EMAIL") as? String,
              let password = Bundle.main.object(forInfoDictionaryKey: "DEV_TEST_PASSWORD") as? String,
              !email.isEmpty, !password.isEmpty else {
            throw NetworkError.invalidRequest
        }
        @Dependency(\.authenticatedHTTPClient) var client
        return try await client.request(DevTestAccountRequest(email: email, password: password))
    }
}
#endif
