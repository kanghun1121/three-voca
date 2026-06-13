import Foundation

import Core

struct CompleteSessionRequest: Requestable {
    let sessionID: Int

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/rest/v1/rpc/complete_session" }
    var method: HTTPMethod { .post }
    var bodyParameters: HTTPBody { .json(Params(pSessionId: sessionID)) }
    var headers: [String: String] {
        [
            "apikey": SupabaseConfig.anonKey,
            "Accept": "application/json"
        ]
    }
}

private struct Params: Encodable {
    let pSessionId: Int

    enum CodingKeys: String, CodingKey {
        case pSessionId = "p_session_id"
    }
}

struct CompleteSessionResponseDTO: Decodable {
    let success: Bool
}
