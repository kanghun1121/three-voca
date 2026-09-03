import Foundation

import Dependencies

/// 챗봇 메시지 전송 및 SSE 스트리밍 응답 수신을 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct ChatRepository: Sendable {
    public var streamMessage: @Sendable (_ message: String) -> AsyncThrowingStream<String, Error>

    public init(
        streamMessage: @escaping @Sendable (_ message: String) -> AsyncThrowingStream<String, Error>
    ) {
        self.streamMessage = streamMessage
    }
}

extension ChatRepository: TestDependencyKey {
    public static let testValue = ChatRepository(
        streamMessage: unimplemented("\(Self.self).streamMessage")
    )
}

public extension DependencyValues {
    var chatRepository: ChatRepository {
        get { self[ChatRepository.self] }
        set { self[ChatRepository.self] = newValue }
    }
}
