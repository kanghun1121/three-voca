import Foundation

import Core
import DomainInterface

import Dependencies

extension AuthClient: DependencyKey {
    public static let liveValue = AuthClient(
        signInWithApple: { identityToken in
            let client = HTTPClient()
            let request = ExchangeAppleTokenRequest(identityToken: identityToken)
            let dto: AuthTokenResponseDTO = try await client.request(request)
            dump(dto)
            return dto.toDomain()
        }
    )
}
