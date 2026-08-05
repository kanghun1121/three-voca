import Foundation

import DomainInterface
import NetworkingInterface

import Dependencies

extension AuthRepository: DependencyKey {
    public static let liveValue = AuthRepository(
        signInWithApple: { identityToken in
            @Dependency(\.authenticatedHTTPClient) var client
            let request = ExchangeAppleTokenRequest(identityToken: identityToken)
            let dto: AuthTokenResponseDTO = try await client.request(request)
            return dto.toDomain()
        }
    )
}
