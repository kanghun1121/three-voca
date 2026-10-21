import Foundation

/// SSE(Server-Sent Events) 한 프레임 — `event:`/`data:` 필드를 빈 줄 기준으로 묶은 단위.
/// data는 여러 `data:` 줄을 개행으로 이어붙인 값이다. `SSEClienting`의 반환 타입이므로 이벤트
/// 스키마 해석(예: Claude Messages API 이벤트 매핑) 없이 프레임 그 자체만 표현한다 — 해석은
/// 호출자(Data 레이어)의 책임이다.
public struct SSEFrame: Sendable, Equatable {
    public let event: String?
    public let data: String

    public init(event: String?, data: String) {
        self.event = event
        self.data = data
    }
}
