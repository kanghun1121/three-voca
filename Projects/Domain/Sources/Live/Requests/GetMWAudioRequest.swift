import Core
import Foundation

struct GetMWAudioRequest: Requestable {
    let term: String

    var baseURL: URL { MerriamWebsterConfig.baseURL }
    var path: String { "/api/v3/references/collegiate/json/\(term)" }
    var method: HTTPMethod { .get }
    var queryParameters: (any Encodable)? { Params(key: MerriamWebsterConfig.apiKey) }
}

private struct Params: Encodable {
    let key: String
}
