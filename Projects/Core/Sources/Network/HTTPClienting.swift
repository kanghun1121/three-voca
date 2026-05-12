import Foundation

public protocol HTTPClienting {
    func request<T: Decodable>(_ requestable: any Requestable, accessToken: String?) async throws -> T
    func request(_ requestable: any Requestable, accessToken: String?) async throws
}

public extension HTTPClienting {
    func request<T: Decodable>(_ requestable: any Requestable) async throws -> T {
        try await request(requestable, accessToken: nil)
    }

    func request(_ requestable: any Requestable) async throws {
        try await request(requestable, accessToken: nil)
    }
}
