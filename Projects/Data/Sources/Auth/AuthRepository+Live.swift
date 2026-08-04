import Foundation

import DomainInterface
import Networking
import NetworkingInterface

import Dependencies

extension AuthRepository: DependencyKey {
    public static let liveValue = AuthRepository(
        signInWithApple: { identityToken in
            let client = HTTPClient(interceptor: TokenRefreshInterceptor())
            let request = ExchangeAppleTokenRequest(identityToken: identityToken)
            let dto: AuthTokenResponseDTO = try await client.request(request)
            return dto.toDomain()
        }
    )
}
