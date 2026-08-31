import Foundation

import NetworkingInterface

@testable import Networking

/// `feed`/`flush`가 각각 고정된 `SSEFrame`을 반환하는 테스트용 최소 `SSEFraming` 구현. 실제 SSE
/// 텍스트 파싱과 무관하게 `SSEClient`의 오케스트레이션(빈 프레임 스킵, flush 결과 방출)만 검증할 때
/// 쓴다.
struct StubSSEFraming: SSEFraming {
    var feedResult: SSEFrame
    var flushResult: SSEFrame

    mutating func feed(_ line: String) -> SSEFrame { feedResult }
    mutating func flush() -> SSEFrame { flushResult }
}
