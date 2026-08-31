import Foundation

import DomainInterface

import Dependencies

@Observable
@MainActor
public final class ChatBotViewModel {
    let context: ChatBotContext
    var input: String = ""
    private(set) var messages: [ChatBotMessage] = []
    private(set) var isStreaming: Bool = false
    private(set) var errorMessage: String?

    @ObservationIgnored @Dependency(\.sendChatMessageUseCase) private var sendChatMessageUseCase
    // 테스트에서 스트림 종료를 결정론적으로 기다리기 위해 노출한다
    // (WordGame의 SpellingViewModel.advanceTask와 같은 방식).
    @ObservationIgnored private(set) var streamTask: Task<Void, Never>?

    /// 단어 하나가 공개된 뒤 다음 단어로 넘어가기 전 대기 시간. 이 값이 클수록 타이핑 효과가 느려진다.
    private static let wordRevealDelay: Duration = .milliseconds(80)

    public init(context: ChatBotContext) {
        self.context = context
    }

    var canSend: Bool {
        !isStreaming && !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func didTapSend() {
        let message = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isStreaming, !message.isEmpty else { return }

        input = ""
        errorMessage = nil
        isStreaming = true

        messages.append(ChatBotMessage(role: .user, text: message))
        messages.append(ChatBotMessage(
            role: .assistant,
            text: "",
            isGenerating: true
        ))
        let assistantIndex = messages.count - 1

        streamTask = Task {
            do {
                for try await chunk in sendChatMessageUseCase.execute(message) {
                    // 청크 하나를 통째로 붙이면 그 안의 여러 단어가 한 프레임에 동시 등장한다.
                    // 단어 경계로 쪼개 하나씩 붙이고, 다음 단어로 넘어가기 전 wordRevealDelay만큼
                    // 대기해 타이핑처럼 천천히 펼쳐지게 한다.
                    for word in Self.wordChunks(of: chunk) {
                        messages[assistantIndex].isGenerating = false
                        messages[assistantIndex].text += word
                        // try?로 삼키면 취소된 뒤에도 루프가 멈추지 않고 남은 단어를 계속
                        // 쏟아낸다 — 취소를 그대로 던져 즉시 멈추게 한다.
                        try await Task.sleep(for: Self.wordRevealDelay)
                    }
                }
            } catch {
                // 사용자가 직접 멈춘 건 실패가 아니다 — 조용히 끝내고 받은 텍스트를 남긴다.
                // CancellationError는 취소된 태스크에서만 나오므로 Task.isCancelled 하나로 충분하다.
                if !Task.isCancelled {
                    print("[ChatBot] 스트리밍 실패:", error)
                    errorMessage = "응답을 받아오지 못했습니다."
                }
            }
            // 종료 사유(성공/실패/취소)와 무관하게, 한 글자도 못 받은 자리표시는 남기지 않는다.
            if messages[assistantIndex].text.isEmpty {
                messages.remove(at: assistantIndex)
            }
            isStreaming = false
        }
    }

    /// 취소 버튼 탭 시 호출 — 진행 중인 스트림 Task를 취소한다. `isStreaming`은 여기서
    /// 내리지 않는다: 취소된 Task의 종료 처리(위 didTapSend의 do/catch 이후)가 끝난 뒤
    /// 내려야, 정리되기 전에 새 전송이 시작돼 두 스트림이 겹치는 일이 없다.
    func didTapCancel() {
        streamTask?.cancel()
    }

    func onDisappear() {
        streamTask?.cancel()
    }

    /// 텍스트를 "단어 + 그 뒤에 붙는 공백"들로 쪼갠다. 순서대로 이어 붙이면 원문과 정확히
    /// 같아지므로, 델타 텍스트를 여러 조각으로 나눠도 내용 손실이나 공백 뭉개짐이 없다.
    private static func wordChunks(of text: String) -> [String] {
        var result: [String] = []
        var current = ""
        for character in text {
            current.append(character)
            if character.isWhitespace {
                result.append(current)
                current = ""
            }
        }
        if !current.isEmpty {
            result.append(current)
        }
        return result
    }
}
