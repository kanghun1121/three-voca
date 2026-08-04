import SwiftUI

import FeatureVocabulary

import Dependencies

@main
struct VocabularyExampleApp: App {
    init() {
        prepareDependencies {
            $0.getSessionDetailUseCase = .previewValue
            $0.prefetchWordDetailsUseCase = .previewValue
            $0.getWordDetailUseCase = .previewValue
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
            VocabularyListView(viewModel: VocabularyListViewModel(sessionID: "demo"))
        }
    }
}
