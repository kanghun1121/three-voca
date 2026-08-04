import Foundation

import NetworkingInterface

struct GetHeatmapDataRequest: Requestable {
    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/rest/v1/rpc/get_heatmap_data" }
    var method: HTTPMethod { .post }
    var bodyParameters: HTTPBody { .json(EmptyParams()) }
    var headers: [String: String] {
        [
            "apikey": SupabaseConfig.anonKey,
            "Accept": "application/json"
        ]
    }
}

private struct EmptyParams: Encodable {}
