import Foundation

import UseCaseInterface

extension AuthTokenResponseDTO {
    func toDomain() -> AuthToken {
        AuthToken(
            accessToken: accessToken,
            expiresIn: expiresIn,
            expiresAt: expiresAt,
            refreshToken: refreshToken
        )
    }
}
