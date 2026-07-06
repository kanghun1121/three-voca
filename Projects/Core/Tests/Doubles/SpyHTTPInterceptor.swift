//
//  SpyHTTPInterceptor.swift
//  CoreTests
//
//  Created by 강대훈 on 7/6/26.
//  Copyright © 2026 FiveVoca. All rights reserved.
//

import Foundation

@testable import Core

/// `adapt`/`retry` 호출 여부·횟수·결과를 기록하는 스파이 인터셉터.
final class SpyHTTPInterceptor: HTTPInterceptor, @unchecked Sendable {
    var retryResult = false

    private let lock = NSLock()
    private var _adaptCallCount = 0
    private var _retryCallCount = 0
    private var _lastAdaptedRequest: URLRequest?

    var adaptCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _adaptCallCount
    }

    var retryCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _retryCallCount
    }

    var lastAdaptedRequest: URLRequest? {
        lock.lock(); defer { lock.unlock() }
        return _lastAdaptedRequest
    }

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adapted = request
        adapted.setValue("Bearer stub-token", forHTTPHeaderField: "Authorization")

        lock.lock()
        _adaptCallCount += 1
        _lastAdaptedRequest = adapted
        lock.unlock()

        return adapted
    }

    func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool {
        lock.lock()
        _retryCallCount += 1
        lock.unlock()

        return retryResult
    }
}
