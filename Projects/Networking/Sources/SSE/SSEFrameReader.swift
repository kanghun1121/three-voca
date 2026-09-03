import Foundation

import NetworkingInterface

/// SSE 라인을 프레임 단위로 모으는 순수 상태 리듀서. 한 줄씩 `feed`하면 빈 줄에서 지금까지 모은
/// 프레임을 반환한다 — 아직 조립 중이라 반환할 프레임이 없으면 `SSEFrame(event: nil, data: "")`
/// (빈 프레임)을 반환한다. 이 리더가 실제로 다루는 프레임은 전부 JSON `type` 필드를 포함한 비어있지
/// 않은 `data`를 갖기 때문에 "빈 데이터"와 "아직 없음"을 같은 값으로 취급해도 안전하다 — 그 대가로
/// 호출부가 `Optional` 언래핑 없이 `frame.data.isEmpty`만 확인하면 된다. WHATWG SSE 스펙 중 이
/// 클라이언트가 실제로 쓰는 부분만 구현한다 — `event`/`data` 필드, 값 앞 공백 1개 제거. `id`/`retry`는
/// 쓰지 않아 무시하고, 콜론으로 시작하는 주석 줄은 field가 빈 문자열이 되어 switch default로 자연히
/// 걸러진다.
///
/// **실측으로 발견한 보조 경계 신호**: `URLSession.bytes(for:).lines`는 실제로 SSE 프레임을 구분하는
/// 빈 줄을 빈 문자열로 넘겨주지 않는 경우가 있다(Claude Messages API 실 스트림으로 확인됨 — 라인 자체는
/// `\n` 기준으로 정확히 쪼개지지만, 빈 줄만 별도 원소로 나오지 않고 사라진다). 빈 줄에만 의존하면
/// EOF까지 아무 프레임도 dispatch되지 않아 전체 스트림이 한 프레임으로 뭉개진다. 그래서 `event:` 라인이
/// 도착했는데 이미 누적된 `data`가 있으면 — 빈 줄 구분자 없이 바로 다음 프레임이 시작된 것으로 보고
/// 이전 프레임을 먼저 dispatch한다. `data:` 없이 `event:`만 연속으로 와도(빈 프레임) 오탐하지 않도록
/// `dataLines`가 비어있지 않을 때만 트리거한다.
///
/// async 스트림이 아니라 동기 값 타입인 이유: 소비자는 `SSEClient` 하나뿐이라, 별도
/// AsyncThrowingStream/Task로 감쌀 필요 없이 그 소비자의 루프 안에서 바로 호출할 수 있다.
struct SSEFrameReader {
    private var eventName: String?
    private var dataLines: [String] = []

    private static let empty = SSEFrame(event: nil, data: "")

    mutating func feed(_ line: String) -> SSEFrame {
        if line.isEmpty { return dispatch() }

        guard let colonIndex = line.firstIndex(of: ":") else { return Self.empty }
        let field = line[line.startIndex..<colonIndex]
        var value = String(line[line.index(after: colonIndex)...])
        if value.hasPrefix(" ") { value.removeFirst() }

        switch field {
            case "event":
                // 이미 누적된 데이터가 있는 채로 새 event: 라인이 오면, 빈 줄 구분자 없이 다음
                // 프레임이 곧바로 시작된 것 — 이전 프레임을 먼저 내보낸다.
                guard dataLines.isEmpty else {
                    let frame = dispatch()
                    eventName = value
                    return frame
                }
                eventName = value
            case "data": dataLines.append(value)
            default: break
        }

        return Self.empty
    }

    /// 빈 줄 없이 EOF에 도달했을 때 남아있는 데이터를 방어적으로 꺼낸다.
    mutating func flush() -> SSEFrame { dispatch() }

    private mutating func dispatch() -> SSEFrame {
        defer {
            eventName = nil
            dataLines = []
        }
        guard !dataLines.isEmpty else { return Self.empty }
        return SSEFrame(event: eventName, data: dataLines.joined(separator: "\n"))
    }
}
