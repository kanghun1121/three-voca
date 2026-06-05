import Core
import Foundation

struct DownloadMP3Request: Requestable {
    let url: URL
    var baseURL: URL { url }
    var path: String { "" }
    var method: HTTPMethod { .get }

    // appendingPathComponent("") 가 trailing slash를 붙이므로 URL을 그대로 사용한다.
    func makeURLRequest() throws -> URLRequest {
        URLRequest(url: url)
    }
}
