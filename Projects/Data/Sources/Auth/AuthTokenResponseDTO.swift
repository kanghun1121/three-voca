import Foundation

struct AuthTokenResponseDTO: Decodable {
    let accessToken: String
    let expiresIn: Int
    let expiresAt: Int
    let refreshToken: String
}
