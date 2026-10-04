import SwiftUI

import DomainInterface
import FeatureWordGame

import Dependencies

@main
struct WordGameExampleApp: App {
    init() {
        prepareDependencies {
            $0.lessonRepository = .happyPath
            $0.audioRepository.prefetch = { _ in }
            // [TestDependencyKey 제거] previewValue도 unimplemented가 되어 인라인
            $0.completeLessonUseCase = CompleteLessonUseCase(execute: { _ in })
        }
    }

    var body: some Scene {
        WindowGroup {
            WordGameCaseListView()
        }
    }
}

/// 워드게임을 시작할 단계 시나리오. 단어는 모두 `LessonRepository.happyPath`의 경계 단어 4개를 쓴다.
private enum WordGameCase: String, CaseIterable, Identifiable {
    case recognition = "Recognition 부터"
    case multipleChoice = "MultipleChoice 부터"
    case spelling = "Spelling 부터"

    var id: Self { self }

    @MainActor
    func makeViewModel() -> WordGameViewModel {
        switch self {
        case .recognition: WordGameViewModel(lessonID: "demo", startingFrom: .recognition)
        case .multipleChoice: WordGameViewModel(lessonID: "demo", startingFrom: .multipleChoice)
        case .spelling: WordGameViewModel(lessonID: "demo", startingFrom: .spelling)
        }
    }
}

/// 시나리오를 고르는 진입 화면. 항목을 누르면 해당 단계부터 워드게임이 열린다.
private struct WordGameCaseListView: View {
    var body: some View {
        NavigationStack {
            List(WordGameCase.allCases) { gameCase in
                NavigationLink(gameCase.rawValue) {
                    WordGameView(viewModel: gameCase.makeViewModel())
                }
            }
            .navigationTitle("워드게임 시나리오")
        }
    }
}
