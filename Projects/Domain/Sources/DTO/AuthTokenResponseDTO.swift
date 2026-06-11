import Foundation

struct AuthTokenResponseDTO: Decodable {
    let accessToken: String
    let expiresIn: Int
    let expiresAt: Int
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case refreshToken = "refresh_token"
    }
}
