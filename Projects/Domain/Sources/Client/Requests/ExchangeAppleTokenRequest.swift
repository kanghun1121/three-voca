import Foundation

import Core

struct ExchangeAppleTokenRequest: Requestable {
    let identityToken: String

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/auth/v1/token" }
    var method: HTTPMethod { .post }
    var queryParameters: (any Encodable)? { GrantTypeQuery() }
    var bodyParameters: HTTPBody { .json(Body(idToken: identityToken)) }
    var headers: [String: String] {
        ["apikey": SupabaseConfig.anonKey]
    }
}

private struct GrantTypeQuery: Encodable {
    let grant_type = "id_token"
}

private struct Body: Encodable {
    let provider = "apple"
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case provider
        case idToken = "id_token"
    }
}
