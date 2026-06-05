import Foundation

public struct HTTPClient: HTTPClienting {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared, decoder: JSONDecoder? = nil) {
        self.session = session
        self.decoder = decoder ?? {
            let d = JSONDecoder()
            d.keyDecodingStrategy = .convertFromSnakeCase
            return d
        }()
    }

    public func request<T: Decodable>(_ requestable: any Requestable) async throws -> T {
        let (data, response) = try await perform(requestable)
        try validate(response, data: data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    public func request(_ requestable: any Requestable) async throws {
        let (data, response) = try await perform(requestable)
        try validate(response, data: data)
        _ = data
    }

    public func requestData(_ requestable: any Requestable) async throws -> Data {
        let (data, response) = try await perform(requestable)
        try validate(response, data: data)
        return data
    }

    // MARK: - Private

    private func perform(_ requestable: any Requestable) async throws -> (Data, URLResponse) {
        var urlRequest: URLRequest
        do {
            urlRequest = try requestable.makeURLRequest()
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.invalidRequest
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            return (data, response)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.httpError(statusCode: http.statusCode, data: data)
        }
    }
}
