//
//  StubHTTPClienting.swift
//  DomainTests
//
//  Created by 강대훈 on 7/6/26.
//

import Foundation

import Core

/// `HTTPClienting`의 테스트용 최소 구현. `resultProvider`가 반환/throw하는 값을 그대로 전달한다.
final class StubHTTPClienting: HTTPClienting, @unchecked Sendable {
    var resultProvider: (@Sendable () throws -> Any)?

    private let lock = NSLock()
    private var _requestCallCount = 0

    var requestCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _requestCallCount
    }

    func request<T: Decodable>(_ requestable: any Requestable) async throws -> T {
        lock.lock(); _requestCallCount += 1; lock.unlock()

        guard let provider = resultProvider else {
            fatalError("StubHTTPClienting.resultProvider가 설정되지 않았습니다.")
        }
        guard let value = try provider() as? T else {
            fatalError("StubHTTPClienting: 반환 타입이 \(T.self)와 일치하지 않습니다.")
        }
        return value
    }

    func request(_ requestable: any Requestable) async throws {
        lock.lock(); _requestCallCount += 1; lock.unlock()
        _ = try resultProvider?()
    }
}
