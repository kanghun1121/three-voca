import Foundation

import Core
import DomainInterface

import Dependencies

extension AuthClient: DependencyKey {
    public static let liveValue: AuthClient = {
        let authSessionClient = AuthSessionClient.liveValue
        let client = HTTPClient(interceptor: TokenRefreshInterceptor())

        return AuthClient(
            signInWithApple: { identityToken in
                let request = ExchangeAppleTokenRequest(identityToken: identityToken)
                let dto: AuthTokenResponseDTO = try await client.request(request)
                let token = dto.toDomain()
                await authSessionClient.setAccessToken(token.accessToken)
                try authSessionClient.setRefreshToken(token.refreshToken)
                return token
            },
            checkSession: {
                guard let refreshToken = try? authSessionClient.getRefreshToken() else {
                    try? await authSessionClient.clearSession()
                    return
                }
                do {
                    let noopClient = HTTPClient()
                    let request = RefreshTokenRequest(refreshToken: refreshToken)
                    let dto: AuthTokenResponseDTO = try await noopClient.request(request)
                    let token = dto.toDomain()
                    await authSessionClient.setAccessToken(token.accessToken)
                    try authSessionClient.setRefreshToken(token.refreshToken)
                } catch {
                    try? await authSessionClient.clearSession()
                }
            }
        )
    }()
}
