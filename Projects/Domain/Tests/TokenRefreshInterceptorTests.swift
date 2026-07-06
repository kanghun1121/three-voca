//
//  TokenRefreshInterceptorTests.swift
//  DomainTests
//
//  Created by 강대훈 on 7/6/26.
//

import XCTest

import DomainInterface

import Dependencies

@testable import Domain

final class TokenRefreshInterceptorTests: XCTestCase {
    func test_adapt_accessToken이_있으면_Authorization_헤더를_부착한다() async throws {
        let sut = withDependencies {
            $0.authSessionClient.getAccessToken = { "access-token-123" }
        } operation: {
            TokenRefreshInterceptor()
        }
        let original = URLRequest(url: URL(string: "https://example.com")!)

        let adapted = try await sut.adapt(original)

        XCTAssertEqual(adapted.value(forHTTPHeaderField: "Authorization"), "Bearer access-token-123")
    }

    func test_adapt_accessToken이_없으면_원본_요청을_그대로_반환한다() async throws {
        let sut = withDependencies {
            $0.authSessionClient.getAccessToken = { nil }
        } operation: {
            TokenRefreshInterceptor()
        }
        let original = URLRequest(url: URL(string: "https://example.com")!)

        let adapted = try await sut.adapt(original)

        XCTAssertNil(adapted.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(adapted, original)
    }

    func test_retry_401이_아니면_false를_반환하고_refresh_로직을_실행하지_않는다() async {
        // authSessionClient/httpClient를 오버라이드하지 않아 testValue(unimplemented)가 그대로 유지된다.
        // guard에서 반환되지 않고 refresh 로직이 실행되면 unimplemented가 테스트를 실패시킨다.
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

    func test_retry_401이고_refresh가_성공하면_토큰을_저장하고_true를_반환한다() async {
        let recorder = AuthSessionRecorder()
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
            $0.authSessionClient.getRefreshToken = { "old-refresh-token" }
            $0.authSessionClient.setAccessToken = { recorder.recordSetAccessToken($0) }
            $0.authSessionClient.setRefreshToken = { recorder.recordSetRefreshToken($0) }
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
        XCTAssertEqual(recorder.setAccessTokenCallCount, 1)
        XCTAssertEqual(recorder.lastSetAccessToken, "new-access-token")
        XCTAssertEqual(recorder.setRefreshTokenCallCount, 1)
        XCTAssertEqual(recorder.lastSetRefreshToken, "new-refresh-token")
        XCTAssertEqual(recorder.clearSessionCallCount, 0)
    }

    func test_retry_401이고_refreshToken_조회가_실패하면_clearSession_후_false를_반환한다() async {
        let recorder = AuthSessionRecorder()

        let sut = withDependencies {
            $0.authSessionClient.getRefreshToken = { throw MockError.stub }
            $0.authSessionClient.clearSession = { recorder.recordClearSession() }
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
        XCTAssertEqual(recorder.clearSessionCallCount, 1)
    }

    func test_retry_401이고_refresh_API_호출이_실패하면_clearSession_후_false를_반환한다() async {
        let recorder = AuthSessionRecorder()
        let stubHTTPClient = StubHTTPClienting()
        stubHTTPClient.resultProvider = { throw MockError.stub }

        let sut = withDependencies {
            $0.httpClient = stubHTTPClient
            $0.authSessionClient.getRefreshToken = { "old-refresh-token" }
            $0.authSessionClient.clearSession = { recorder.recordClearSession() }
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
        XCTAssertEqual(recorder.clearSessionCallCount, 1)
    }
}

private enum MockError: Error {
    case stub
}
