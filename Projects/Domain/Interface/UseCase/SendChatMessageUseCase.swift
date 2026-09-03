import Foundation

import Dependencies

/// 챗봇에 메시지를 보내고 응답을 스트리밍으로 받는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct SendChatMessageUseCase: Sendable {
    public var execute: @Sendable (_ message: String) -> AsyncThrowingStream<String, Error>

    public init(execute: @escaping @Sendable (_ message: String) -> AsyncThrowingStream<String, Error>) {
        self.execute = execute
    }
}

extension SendChatMessageUseCase: TestDependencyKey {
    public static let testValue = SendChatMessageUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = SendChatMessageUseCase(
        execute: { _ in
            AsyncThrowingStream { continuation in
                let chunks = ["안녕", "하세요! ", "무엇을 ", "도와드릴까요?"]
                for chunk in chunks {
                    continuation.yield(chunk)
                }
                continuation.finish()
            }
        }
    )
}

public extension DependencyValues {
    var sendChatMessageUseCase: SendChatMessageUseCase {
        get { self[SendChatMessageUseCase.self] }
        set { self[SendChatMessageUseCase.self] = newValue }
    }
}
