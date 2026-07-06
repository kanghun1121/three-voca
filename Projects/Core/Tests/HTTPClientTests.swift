//
//  HTTPClientTests.swift
//  CoreTests
//
//  Created by 강대훈 on 7/6/26.
//  Copyright © 2026 FiveVoca. All rights reserved.
//

import XCTest

@testable import Core

final class HTTPClientTests: XCTestCase {
    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
    }

    func test_request_200응답이면_snakeCase를_변환하여_디코딩한다() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data(#"{"some_value":"hello"}"#.utf8)
            return (response, data)
        }
        
        let sut = HTTPClient(session: MockURLProtocol.makeSession())
        let result: StubDecodable = try await sut.request(StubRequestable())

        XCTAssertEqual(result.someValue, "hello")
    }

    func test_request_2xx가_아니면_httpError를_던진다() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let sut = HTTPClient(session: MockURLProtocol.makeSession())

        do {
            let _: StubDecodable = try await sut.request(StubRequestable())
            XCTFail("NetworkError.httpError가 던져져야 합니다.")
        } catch NetworkError.httpError(let statusCode, _) {
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("NetworkError.httpError가 아닌 다른 에러입니다: \(error)")
        }
    }

    func test_request_401응답에서_retry가_true를_반환하면_재요청하여_성공응답을_반환한다() async throws {
        let interceptor = SpyHTTPInterceptor()
        interceptor.retryResult = true

        MockURLProtocol.requestHandler = { request in
            if interceptor.retryCallCount == 0 {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (response, Data())
            } else {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
                let data = Data(#"{"some_value":"retried"}"#.utf8)
                return (response, data)
            }
        }
        let sut = HTTPClient(interceptor: interceptor, session: MockURLProtocol.makeSession())

        let result: StubDecodable = try await sut.request(StubRequestable())

        XCTAssertEqual(result.someValue, "retried")
        XCTAssertEqual(interceptor.retryCallCount, 1)
    }

    func test_request_401응답에서_retry가_false를_반환하면_재요청없이_httpError를_던진다() async {
        let interceptor = SpyHTTPInterceptor()
        interceptor.retryResult = false

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }
        let sut = HTTPClient(interceptor: interceptor, session: MockURLProtocol.makeSession())

        do {
            let _: StubDecodable = try await sut.request(StubRequestable())
            XCTFail("NetworkError.httpError가 던져져야 합니다.")
        } catch NetworkError.httpError(let statusCode, _) {
            XCTAssertEqual(statusCode, 401)
        } catch {
            XCTFail("NetworkError.httpError가 아닌 다른 에러입니다: \(error)")
        }

        XCTAssertEqual(interceptor.retryCallCount, 1)
    }

    func test_request_requiresAuthentication이_true이면_adapt가_호출되어_요청이_변형된다() async throws {
        let interceptor = SpyHTTPInterceptor()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data(#"{"some_value":"ok"}"#.utf8)
            return (response, data)
        }
        let sut = HTTPClient(interceptor: interceptor, session: MockURLProtocol.makeSession())

        _ = try await sut.request(StubRequestable(requiresAuthentication: true)) as StubDecodable

        XCTAssertEqual(interceptor.adaptCallCount, 1)
        XCTAssertEqual(interceptor.lastAdaptedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer stub-token")
    }

    func test_request_requiresAuthentication이_false이면_adapt가_호출되지_않는다() async throws {
        let interceptor = SpyHTTPInterceptor()

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data(#"{"some_value":"ok"}"#.utf8)
            return (response, data)
        }
        let sut = HTTPClient(interceptor: interceptor, session: MockURLProtocol.makeSession())

        _ = try await sut.request(StubRequestable(requiresAuthentication: false)) as StubDecodable

        XCTAssertEqual(interceptor.adaptCallCount, 0)
    }
}

private struct StubDecodable: Decodable, Equatable {
    let someValue: String
}
