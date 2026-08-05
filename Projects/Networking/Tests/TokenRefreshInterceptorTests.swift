//
//  TokenRefreshInterceptorTests.swift
//  DataTests
//
//  Created by 강대훈 on 7/6/26.
//

import XCTest

import DomainInterface

import Dependencies

@testable import Data

final class TokenRefreshInterceptorTests: XCTestCase {
    func test_adapt_accessToken이_있으면_Authorization_헤더를_부착한다() async throws {
        let sut = withDependencies {
            $0.authSessionRepository.getAccessToken = { "access-token-123" }
        } operation: {
            TokenRefreshInterceptor()
        }
        let original = URLRequest(url: URL(string: "https://example.com")!)

        let adapted = try await sut.adapt(original)

        XCTAssertEqual(adapted.value(forHTTPHeaderField: "Authorization"), "Bearer access-token-123")
    }

    func test_adapt_accessToken이_없으면_원본_요청을_그대로_반환한다() async throws {
        let sut = withDependencies {
            $0.authSessionRepository.getAccessToken = { nil }
        } operation: {
            TokenRefreshInterceptor()
        }
        let original = URLRequest(url: URL(string: "https://example.com")!)

        let adapted = try await sut.adapt(original)

        XCTAssertNil(adapted.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(adapted, original)
    }

    func test_retry_401이_아니면_false를_반환하고_refreshAccessToken을_호출하지_않는다() async {
        let sut = TokenRefreshInterceptor()

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertFalse(result)
    }

    func test_retry_401이면_authSessionRepository의_refreshAccessToken_결과를_그대로_반환한다() async {
        let sut = withDependencies {
            $0.authSessionRepository.refreshAccessToken = { true }
        } operation: {
            TokenRefreshInterceptor()
        }

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertTrue(result)
    }

    func test_retry_401이고_refreshAccessToken이_실패하면_false를_반환한다() async {
        let sut = withDependencies {
            $0.authSessionRepository.refreshAccessToken = { false }
        } operation: {
            TokenRefreshInterceptor()
        }

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertFalse(result)
    }
}

private enum MockError: Error {
    case stub
}
