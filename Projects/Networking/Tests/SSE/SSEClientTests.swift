import XCTest

import NetworkingInterface

@testable import Networking

final class SSEClientTests: XCTestCase {
    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
    }

    func test_비2xx_응답이면_httpError로_종료된다() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data(#"{"error":{"message":"invalid api key"}}"#.utf8))
        }

        let sut = SSEClient(session: MockURLProtocol.makeSession())

        do {
            _ = try await collect(sut.stream(StubRequestable()))
            XCTFail("NetworkError.httpError가 던져져야 합니다.")
        } catch NetworkError.httpError(let statusCode, _) {
            XCTAssertEqual(statusCode, 401)
        } catch {
            XCTFail("NetworkError.httpError가 아닌 다른 에러입니다: \(error)")
        }
    }

    /// 프레임 리더를 주입받아 실제 SSE 텍스트 파싱 없이 SSEClient의 오케스트레이션만 검증한다:
    /// feed()의 빈 프레임은 스킵되고(StubSSEFraming.feedResult가 항상 빈 프레임), EOF에서
    /// flush()가 반환한 프레임은 스트림 끝에 방출된다.
    func test_feed의_빈_프레임은_스킵되고_flush_결과는_방출된다() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("x\n".utf8))
        }

        let flushedFrame = SSEFrame(event: "done", data: "trailing")
        let sut = SSEClient(
            session: MockURLProtocol.makeSession(),
            frameReader: StubSSEFraming(feedResult: SSEFrame(event: nil, data: ""), flushResult: flushedFrame)
        )

        let frames = try await collect(sut.stream(StubRequestable()))

        XCTAssertEqual(frames, [flushedFrame])
    }
}

private func collect<S: AsyncSequence>(_ sequence: S) async throws -> [S.Element] {
    var result: [S.Element] = []
    for try await element in sequence {
        result.append(element)
    }
    return result
}
