import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case requestFailed(Error)
}
