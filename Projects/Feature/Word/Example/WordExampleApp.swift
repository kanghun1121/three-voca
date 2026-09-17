import SwiftUI

import FeatureWord

import Dependencies

@main
struct WordExampleApp: App {
    init() {
        prepareDependencies {
            // [TestDependencyKey 제거] previewValue도 unimplemented가 되어 인라인
            $0.loadLessonWordsUseCase = LoadLessonWordsUseCase(execute: { id in .preview(id: id) })
            $0.wordRepository.fetchDetail = { _ in .previewFixture }
            $0.audioRepository.url = { _ in nil }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private struct ContentView: View {
    var body: some View {
        NavigationStack {
            WordListView(viewModel: WordListViewModel(lessonID: "demo"))
        }
    }
}
