import Foundation

public struct AuthToken: Sendable {
    public let accessToken: String
    public let expiresIn: Int
    public let expiresAt: Int
    public let refreshToken: String
    
    public init(
        accessToken: String,
        expiresIn: Int,
        expiresAt: Int,
        refreshToken: String
    ) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
    }
}

public extension AuthToken {
    static let previewFixture = AuthToken(
        accessToken: "preview.access.token",
        expiresIn: 3600,
        expiresAt: 9_999_999_999,
        refreshToken: "preview.refresh.token"
    )
}
