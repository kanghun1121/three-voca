import Foundation

import NetworkingInterface

struct DeleteAccountRequest: Requestable {
    let accessToken: String

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/rest/v1/rpc/delete_account" }
    var method: HTTPMethod { .post }
    var headers: [String: String] {
        [
            "apikey": SupabaseConfig.anonKey,
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
    }
    var requiresAuthentication: Bool { false }
}
