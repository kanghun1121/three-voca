#if DEV_ENVIRONMENT
import Foundation

import NetworkingInterface

struct DevTestAccountRequest: Requestable {
    let email: String
    let password: String

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/auth/v1/token" }
    var method: HTTPMethod { .post }
    var queryParameters: (any Encodable)? { GrantTypeQuery() }
    var bodyParameters: HTTPBody { .json(Body(email: email, password: password)) }
    var headers: [String: String] { ["apikey": SupabaseConfig.anonKey] }
    var requiresAuthentication: Bool { false }

    private struct GrantTypeQuery: Encodable {
        let grantType = "password"

        enum CodingKeys: String, CodingKey {
            case grantType = "grant_type"
        }
    }

    private struct Body: Encodable {
        let email: String
        let password: String
    }
}
#endif
