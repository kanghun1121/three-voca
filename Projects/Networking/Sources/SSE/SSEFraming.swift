import Foundation

import NetworkingInterface

/// `SSEClient`가 실제 SSE 프레임 리딩 구현(`SSEFrameReader`)에 직접 의존하지 않도록 감싸는 내부
/// 포트. `NetworkingInterface`로 노출하지 않는다 — `SSEClienting` 소비자는 이 존재를 몰라도 되고,
/// `SSEClient`가 테스트에서 가짜 구현을 주입받기 위한 내부 구현 세부사항일 뿐이다.
protocol SSEFraming {
    mutating func feed(_ line: String) -> SSEFrame
    mutating func flush() -> SSEFrame
}

extension SSEFrameReader: SSEFraming {}
