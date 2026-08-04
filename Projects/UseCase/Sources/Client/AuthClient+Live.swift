import Foundation

import Core
import UseCaseInterface

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
                _ = await authSessionClient.refreshAccessToken()
            }
        )
    }()
}
