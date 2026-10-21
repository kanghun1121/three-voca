import XCTest

import NetworkingInterface

@testable import Networking

final class SSEFrameReaderTests: XCTestCase {

    func test_event와_data_라인이_있으면_해당_필드로_프레임을_만든다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed("event: message_start").data.isEmpty)
        XCTAssertTrue(reader.feed(#"data: {"type":"message_start"}"#).data.isEmpty)
        XCTAssertEqual(
            reader.feed(""),
            SSEFrame(event: "message_start", data: #"{"type":"message_start"}"#)
        )
    }

    func test_여러_data_줄은_개행으로_이어붙인_하나의_프레임이_된다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed("data: line1").data.isEmpty)
        XCTAssertTrue(reader.feed("data: line2").data.isEmpty)
        XCTAssertEqual(reader.feed(""), SSEFrame(event: nil, data: "line1\nline2"))
    }

    func test_콜론으로_시작하는_주석_줄은_무시된다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed(": keep-alive").data.isEmpty)
        XCTAssertTrue(reader.feed("data: hello").data.isEmpty)
        XCTAssertEqual(reader.feed(""), SSEFrame(event: nil, data: "hello"))
    }

    func test_data가_없는_프레임은_빈줄에서_dispatch되지_않는다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed("event: ping").data.isEmpty)
        XCTAssertTrue(reader.feed("").data.isEmpty, "data가 없으면 프레임이 dispatch되지 않아야 합니다.")
    }

    func test_빈줄_없이_EOF에_도달해도_flush로_남은_데이터를_꺼낼_수_있다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed("data: trailing").data.isEmpty)
        XCTAssertEqual(reader.flush(), SSEFrame(event: nil, data: "trailing"))
    }

    func test_여러_프레임이_연속으로_오면_순서대로_모두_dispatch된다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed("event: a").data.isEmpty)
        XCTAssertTrue(reader.feed("data: 1").data.isEmpty)
        XCTAssertEqual(reader.feed(""), SSEFrame(event: "a", data: "1"))

        XCTAssertTrue(reader.feed("event: b").data.isEmpty)
        XCTAssertTrue(reader.feed("data: 2").data.isEmpty)
        XCTAssertEqual(reader.feed(""), SSEFrame(event: "b", data: "2"))
    }

    /// 실제 Claude Messages API 스트림에서 확인된 경우: `URLSession.bytes(for:).lines`가 SSE
    /// 프레임 구분용 빈 줄을 빈 문자열로 넘겨주지 않아, 빈 줄 없이 event: 라인이 곧바로 다음 프레임을
    /// 시작한다. 이때도 event: 라인 자체가 경계 신호가 되어 이전 프레임이 dispatch돼야 한다.
    func test_빈줄_구분자_없이_event_라인이_곧바로_이어져도_이전_프레임이_dispatch된다() {
        var reader = SSEFrameReader()

        XCTAssertTrue(reader.feed("event: a").data.isEmpty)
        XCTAssertTrue(reader.feed("data: 1").data.isEmpty)

        // 빈 줄 없이 바로 다음 프레임의 event: 라인이 옴
        XCTAssertEqual(reader.feed("event: b"), SSEFrame(event: "a", data: "1"))
        XCTAssertTrue(reader.feed("data: 2").data.isEmpty)
        XCTAssertEqual(reader.flush(), SSEFrame(event: "b", data: "2"))
    }
}
