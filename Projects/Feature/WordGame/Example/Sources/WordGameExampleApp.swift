import SwiftUI

import FeatureWordGame
import DomainInterface

import Dependencies

@main
struct WordGameExampleApp: App {
    init() {
        prepareDependencies {
            $0.sessionClient = .previewWith3Words
        }
    }

    var body: some Scene {
        WindowGroup {
            ExampleRootView()
        }
    }
}

private extension SessionClient {
    static let previewWith3Words = SessionClient(
        fetchSessionDetail: { id in
            Session(
                id: id,
                level: 1,
                sessionNumber: 1,
                estimatedDurationMinutes: 5,
                cefrLevel: "A1",
                words: [
                    Session.Word(
                        id: "w1",
                        term: "apple",
                        pronunciation: "/ˈæp.əl/",
                        definitions: [.init(id: "d1", partOfSpeech: .noun, meaning: "사과")],
                        distractors: ["바나나", "포도", "딸기"]
                    ),
                    Session.Word(
                        id: "w2",
                        term: "brave",
                        pronunciation: "/breɪv/",
                        definitions: [.init(id: "d2", partOfSpeech: .adjective, meaning: "용감한")],
                        distractors: ["겁쟁이", "느린", "조용한"]
                    ),
                    Session.Word(
                        id: "w3",
                        term: "create",
                        pronunciation: "/kriˈeɪt/",
                        definitions: [.init(id: "d3", partOfSpeech: .verb, meaning: "만들다, 창조하다")],
                        distractors: ["파괴하다", "멈추다", "잊다"]
                    ),
                ],
                record: nil
            )
        },
        completeSession: { _ in }
    )
}

struct ExampleRootView: View {
    @State private var destination: WordGameViewModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Recognition 부터") {
                    destination = WordGameViewModel(sessionID: "demo", startingFrom: .recognition)
                }
                Button("MultipleChoice 부터") {
                    destination = WordGameViewModel(sessionID: "demo", startingFrom: .multipleChoice)
                }
                Button("Spelling 부터") {
                    destination = WordGameViewModel(sessionID: "demo", startingFrom: .spelling)
                }
            }
            .navigationDestination(item: $destination) { vm in
                WordGameView(viewModel: vm)
            }
        }
    }
}
