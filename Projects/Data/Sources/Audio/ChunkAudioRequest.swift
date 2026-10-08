import Foundation

import NetworkingInterface

struct ChunkAudioRequest: Requestable {
    let text: String

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "functions/v1/chunk-audio" }
    var method: HTTPMethod { .post }
    var bodyParameters: HTTPBody { .json(Body(text: text)) }
    var requiresAuthentication: Bool { false }

    private struct Body: Encodable {
        let text: String
    }
}
