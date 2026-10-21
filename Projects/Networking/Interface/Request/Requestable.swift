import Foundation

public protocol Requestable {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: (any Encodable)? { get }
    var bodyParameters: HTTPBody { get }
    var headers: [String: String] { get }
    var requiresAuthentication: Bool { get }
}

public extension Requestable {
    var queryParameters: (any Encodable)? { nil }
    var bodyParameters: HTTPBody { .none }
    var headers: [String: String] { [:] }
    var requiresAuthentication: Bool { true }

    func makeURLRequest() throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)

        if let query = try queryParameters?.toDictionary() {
            components?.queryItems = query.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        switch bodyParameters {
        case .json(let value):
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(value)
        case .none:
            break
        }

        return request
    }
}
