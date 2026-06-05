import Core
import Foundation

struct DownloadMP3Request: Requestable {
    let url: URL
    var baseURL: URL { url }
    var path: String { "" }
    var method: HTTPMethod { .get }
}
