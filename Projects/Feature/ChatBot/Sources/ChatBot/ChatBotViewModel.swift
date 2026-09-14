import AuthenticationServices
import Foundation

import Core
import DomainInterface

import Dependencies

@Observable
@MainActor
public final class ChatBotViewModel {
    let context: ChatBotContext
    var input: String = ""
    private(set) var messages: [ChatBotMessage] = []
    private(set) var isStreaming: Bool = false
    private(set) var isShowingLoginRequiredPopup = false
    private var hasLoadedHistory = false

    @ObservationIgnored @Dependency(\.chatRepository) private var chatRepository
    @ObservationIgnored @Dependency(\.checkAuthSessionUseCase) private var checkAuthSessionUseCase
    @ObservationIgnored @Dependency(\.signInWithAppleUseCase) private var signInWithAppleUseCase
    @ObservationIgnored @Dependency(\.loggerClient) private var loggerClient
    @ObservationIgnored private(set) var streamTask: Task<Void, Never>?

    private static let wordRevealDelay: Duration = .milliseconds(10)

    var canSend: Bool {
        !isStreaming && !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public init(context: ChatBotContext) {
        self.context = context
    }

    func load() async {
        isShowingLoginRequiredPopup = !checkAuthSessionUseCase.execute()
        guard !isShowingLoginRequiredPopup, !hasLoadedHistory else { return }

        do {
            for try await history in chatRepository.fetchHistory(context.wordID) {
                apply(history)
            }
            hasLoadedHistory = true
        } catch {
            loggerClient.error("ChatBot", "히스토리 로드 실패: \(error.localizedDescription)")
        }
    }

    func didTapSend() {
        let message = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isStreaming, !message.isEmpty else { return }

        input = ""
        isStreaming = true

        messages.removeAll(where: { $0.isError })

        messages.append(ChatBotMessage(role: .user, text: message))
        messages.append(ChatBotMessage(
            role: .assistant,
            text: "",
            isGenerating: true
        ))
        let assistantIndex = messages.count - 1

        streamTask = Task {
            do {
                for try await chunk in chatRepository.streamMessage(message, context.wordID) {
                    for word in Self.wordChunks(of: chunk) {
                        messages[assistantIndex].isGenerating = false
                        messages[assistantIndex].text += word
                        try await Task.sleep(for: Self.wordRevealDelay)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    loggerClient.error("ChatBot", "스트리밍 실패: \(error.localizedDescription)")
                    messages[assistantIndex].isGenerating = false
                    messages[assistantIndex].text = "답변을 가져오지 못했어요"
                    messages[assistantIndex].isError = true
                }
            }

            if messages[assistantIndex].text.isEmpty {
                messages.remove(at: assistantIndex)
            }

            isStreaming = false
        }
    }

    func didTapStop() {
        Task { try? await chatRepository.stopStreaming(context.wordID) }
    }

    func onDisappear() {
        Task { try? await chatRepository.stopStreaming(context.wordID) }
        streamTask?.cancel()
    }

    func appleLoginRequested(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func appleLoginCompleted(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let identityToken = String(data: tokenData, encoding: .utf8) else { return }
            Task {
                do {
                    _ = try await signInWithAppleUseCase.execute(identityToken)
                    isShowingLoginRequiredPopup = false
                } catch {
                    loggerClient.error("Auth", "signInWithApple 실패: \(error.localizedDescription)")
                }
            }
        case .failure(let error):
            loggerClient.error("Auth", "Apple 로그인 실패: \(error.localizedDescription)")
        }
    }

    func didTapLater() {
        isShowingLoginRequiredPopup = false
    }

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

    private func apply(_ history: ChatHistory) {
        let loadedMessages = history.messages.map { message -> ChatBotMessage in
            let role: ChatBotMessage.Role
            switch message.role {
            case .user: role = .user
            case .assistant: role = .assistant
            }
            return ChatBotMessage(
                role: role,
                text: message.content,
                isFromHistory: true
            )
        }

        // load()는 로컬 캐시 → 원격 순으로 이 메서드를 두 번 호출한다. `ChatBotMessage.id`는
        // 생성마다 새로 발급되는 UUID라, 내용이 같아도 무조건 remove+insert하면 ForEach가
        // 모든 히스토리 행을 새 아이덴티티로 다시 그린다 — 스크롤 위치가 미세하게 밀리며
        // 화면이 끊기는 것처럼 보인다. 내용이 실제로 안 바뀌었으면 아무것도 하지 않는다.
        let currentHistory = messages.filter(\.isFromHistory)
        let isUnchanged = currentHistory.count == loadedMessages.count
            && zip(currentHistory, loadedMessages).allSatisfy { $0.role == $1.role && $0.text == $1.text }
        guard !isUnchanged else { return }

        messages.removeAll(where: \.isFromHistory)
        messages.insert(contentsOf: loadedMessages, at: 0)
    }
}
