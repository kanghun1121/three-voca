import Core
import Foundation

struct GetWordDetailRequest: Requestable {
    let wordID: String

    var baseURL: URL { SupabaseConfig.baseURL }
    var path: String { "/rest/v1/rpc/get_word_detail" }
    var method: HTTPMethod { .get }
    var queryParameters: (any Encodable)? { Params(wordId: numericID) }
    var headers: [String: String] {
        [
            "apikey": SupabaseConfig.anonKey,
            "Accept": "application/json"
        ]
    }

    // "word_766" → "766", "766" → "766"
    private var numericID: String {
        wordID.components(separatedBy: "_").last ?? wordID
    }
}

private struct Params: Encodable {
    let wordId: String

    enum CodingKeys: String, CodingKey {
        case wordId = "word_id"
    }
}
