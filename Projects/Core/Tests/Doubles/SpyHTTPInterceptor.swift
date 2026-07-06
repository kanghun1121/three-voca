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

    var adaptCallCount = 0
    var retryCallCount = 0
    var lastAdaptedRequest: URLRequest?

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adapted = request
        adapted.setValue("Bearer stub-token", forHTTPHeaderField: "Authorization")

        adaptCallCount += 1
        lastAdaptedRequest = adapted

        return adapted
    }

    func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool {
        retryCallCount += 1
        return retryResult
    }
}
