import Foundation

/// SSE(Server-Sent Events) 스트리밍 요청을 추상화한 포트. `HTTPClienting`과 동일한 패턴으로
/// `Requestable`을 그대로 실행하고 응답을 SSE 프레임 단위로 흘려보내기만 한다 — 프레임의 이벤트
/// 스키마 해석(예: Claude Messages API 이벤트 매핑)은 이 포트의 책임이 아니라 호출자(Data 레이어)의
/// 책임이다. 인증이 필요하면 Requestable의 headers에 직접 담는다 — HTTPClienting 계열의
/// TokenRefreshInterceptor 파이프라인은 타지 않는다.
public protocol SSEClienting {
    func stream(_ requestable: any Requestable) -> AsyncThrowingStream<SSEFrame, Error>
}
