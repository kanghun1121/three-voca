//
//  TokenRefreshInterceptorTests.swift
//  DomainTests
//
//  Created by 강대훈 on 7/6/26.
//

import XCTest

import Dependencies

@testable import Domain

final class TokenRefreshInterceptorTests: XCTestCase {
    func test_adapt_accessToken이_있으면_Authorization_헤더를_부착한다() async throws {
        let authSpy = AuthSessionClientSpy()
        authSpy.accessTokenToReturn = "access-token-123"

        let sut = TokenRefreshInterceptor(authSessionClient: authSpy.asClient)
        let original = URLRequest(url: URL(string: "https://example.com")!)

        let adapted = try await sut.adapt(original)

        XCTAssertEqual(adapted.value(forHTTPHeaderField: "Authorization"), "Bearer access-token-123")
    }

    func test_adapt_accessToken이_없으면_원본_요청을_그대로_반환한다() async throws {
        let authSpy = AuthSessionClientSpy()
        authSpy.accessTokenToReturn = nil

        let sut = TokenRefreshInterceptor(authSessionClient: authSpy.asClient)
        let original = URLRequest(url: URL(string: "https://example.com")!)

        let adapted = try await sut.adapt(original)

        XCTAssertNil(adapted.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(adapted, original)
    }

    func test_retry_401이_아니면_false를_반환하고_refresh_로직을_실행하지_않는다() async {
        let authSpy = AuthSessionClientSpy()
        let stubHTTPClient = StubHTTPClienting()

        let sut = withDependencies {
            $0.httpClient = stubHTTPClient
        } operation: {
            TokenRefreshInterceptor(authSessionClient: authSpy.asClient)
        }

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertFalse(result)
        XCTAssertEqual(authSpy.getRefreshTokenCallCount, 0)
        XCTAssertEqual(stubHTTPClient.requestCallCount, 0)
    }

    func test_retry_401이고_refresh가_성공하면_토큰을_저장하고_true를_반환한다() async {
        let authSpy = AuthSessionClientSpy()
        authSpy.refreshTokenResult = .success("old-refresh-token")
        let stubHTTPClient = StubHTTPClienting()
        stubHTTPClient.resultProvider = {
            AuthTokenResponseDTO(
                accessToken: "new-access-token",
                expiresIn: 3600,
                expiresAt: 9_999_999_999,
                refreshToken: "new-refresh-token"
            )
        }

        let sut = withDependencies {
            $0.httpClient = stubHTTPClient
        } operation: {
            TokenRefreshInterceptor(authSessionClient: authSpy.asClient)
        }

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertTrue(result)
        XCTAssertEqual(authSpy.setAccessTokenCallCount, 1)
        XCTAssertEqual(authSpy.lastSetAccessToken, "new-access-token")
        XCTAssertEqual(authSpy.setRefreshTokenCallCount, 1)
        XCTAssertEqual(authSpy.lastSetRefreshToken, "new-refresh-token")
        XCTAssertEqual(authSpy.clearSessionCallCount, 0)
    }

    func test_retry_401이고_refreshToken_조회가_실패하면_clearSession_후_false를_반환한다() async {
        let authSpy = AuthSessionClientSpy()
        authSpy.refreshTokenResult = .failure(MockError.stub)
        let stubHTTPClient = StubHTTPClienting()

        let sut = withDependencies {
            $0.httpClient = stubHTTPClient
        } operation: {
            TokenRefreshInterceptor(authSessionClient: authSpy.asClient)
        }

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertFalse(result)
        XCTAssertEqual(authSpy.clearSessionCallCount, 1)
        XCTAssertEqual(stubHTTPClient.requestCallCount, 0)
    }

    func test_retry_401이고_refresh_API_호출이_실패하면_clearSession_후_false를_반환한다() async {
        let authSpy = AuthSessionClientSpy()
        let stubHTTPClient = StubHTTPClienting()
        stubHTTPClient.resultProvider = { throw MockError.stub }

        let sut = withDependencies {
            $0.httpClient = stubHTTPClient
        } operation: {
            TokenRefreshInterceptor(authSessionClient: authSpy.asClient)
        }

        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )

        let result = await sut.retry(dueTo: MockError.stub, response: response)

        XCTAssertFalse(result)
        XCTAssertEqual(authSpy.clearSessionCallCount, 1)
        XCTAssertEqual(authSpy.setAccessTokenCallCount, 0)
    }
}

private enum MockError: Error {
    case stub
}
