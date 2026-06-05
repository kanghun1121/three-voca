import Foundation

public protocol HTTPClienting {
    func request<T: Decodable>(_ requestable: any Requestable) async throws -> T
    func request(_ requestable: any Requestable) async throws
    func requestData(_ requestable: any Requestable) async throws -> Data
}
