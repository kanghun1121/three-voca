import Foundation

import Core
import DomainInterface

import Dependencies

extension AuthClient: DependencyKey {
    public static let liveValue: AuthClient = {
        let authSessionClient = AuthSessionClient.liveValue
        return AuthClient(
            signInWithApple: { identityToken in
                let client = HTTPClient()
                let request = ExchangeAppleTokenRequest(identityToken: identityToken)
                let dto: AuthTokenResponseDTO = try await client.request(request)
                let token = dto.toDomain()
                await authSessionClient.setAccessToken(token.accessToken)
                try authSessionClient.setRefreshToken(token.refreshToken)
                return token
            }
        )
    }()
}
