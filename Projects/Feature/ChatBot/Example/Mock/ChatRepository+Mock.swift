import Foundation

import DomainInterface

extension ChatRepository {
    /// 서버 없이 고정 마크다운 응답(`MarkdownSample.fullResponse`)을 스트리밍하는 정상 흐름. 히스토리는 비어 있다.
    static let happyPath = ChatRepository(
        streamMessage: { _, _ in
            AsyncThrowingStream { continuation in
                continuation.yield(MarkdownSample.fullResponse)
                continuation.finish()
            }
        },
        fetchHistory: { _ in
            AsyncThrowingStream { continuation in
                continuation.yield(ChatHistory(messages: []))
                continuation.finish()
            }
        },
        stopStreaming: { _ in }
    )
}
