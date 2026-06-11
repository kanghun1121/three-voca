import Foundation

import Core

struct RefreshTokenRequest: Requestable {
    let refreshToken: String

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/auth/v1/token" }
    var method: HTTPMethod { .post }
    var queryParameters: (any Encodable)? { GrantTypeQuery() }
    var bodyParameters: HTTPBody { .json(Body(refreshToken: refreshToken)) }
    var headers: [String: String] { ["apikey": SupabaseConfig.anonKey] }
    var requiresAuthentication: Bool { false }
}

private struct GrantTypeQuery: Encodable {
    let grant_type = "refresh_token"
}

private struct Body: Encodable {
    let refreshToken: String
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
