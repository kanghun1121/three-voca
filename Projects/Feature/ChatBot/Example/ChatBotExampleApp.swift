import SwiftUI

import DomainInterface
import FeatureChatBot

import Dependencies

@main
struct ChatBotExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ChatBotCaseListView()
        }
    }
}

/// 챗봇 화면의 확인 시나리오. 서버와 인증은 모두 Mock이라 실제 리소스를 사용하지 않는다.
private enum ChatBotCase: String, CaseIterable, Identifiable {
    case loginRequired = "로그인 화면 띄움"
    case loggedIn = "로그인 화면 없음"

    var id: Self { self }

    @MainActor
    func makeViewModel() -> ChatBotViewModel {
        withDependencies {
            $0.chatRepository = .happyPath
            $0.signInWithAppleUseCase = .happyPath
            switch self {
            case .loginRequired: $0.checkAuthSessionUseCase = .loggedOut
            case .loggedIn: $0.checkAuthSessionUseCase = .loggedIn
            }
        } operation: {
            ChatBotViewModel(context: ChatBotCase.context)
        }
    }

    private static let context = ChatBotContext(
        wordID: "word_766",
        term: "address",
        sentence: "Please write your home address on this form.",
        levelLabel: "초급"
    )
}

/// 시나리오를 고르는 진입 화면. 항목을 누르면 해당 시나리오로 챗봇 화면이 열린다.
private struct ChatBotCaseListView: View {
    var body: some View {
        NavigationStack {
            List(ChatBotCase.allCases) { chatBotCase in
                NavigationLink(chatBotCase.rawValue) {
                    ChatBotView(viewModel: chatBotCase.makeViewModel())
                }
            }
            .navigationTitle("챗봇 시나리오")
        }
    }
}
