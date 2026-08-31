import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case requestFailed(Error)
    /// SSE 스트림 도중 `event: error` 프레임을 수신했을 때
    case streamError(message: String)
}
