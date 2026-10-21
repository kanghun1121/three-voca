import Foundation

public protocol HTTPInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool
}

public struct NoopInterceptor: HTTPInterceptor {
    public init() {}
    public func adapt(_ request: URLRequest) async throws -> URLRequest { request }
    public func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool { false }
}
