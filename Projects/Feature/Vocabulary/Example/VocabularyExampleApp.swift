import Dependencies
import FeatureVocabulary
import SwiftUI

@main
struct VocabularyExampleApp: App {
    init() {
        prepareDependencies {
            $0.sessionClient = .previewValue
            $0.wordClient = .previewValue
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
