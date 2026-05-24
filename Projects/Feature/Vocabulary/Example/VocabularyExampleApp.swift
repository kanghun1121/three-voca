import Dependencies
import FeatureVocabulary
import SwiftUI

@main
struct VocabularyExampleApp: App {
    init() {
        prepareDependencies {
            $0.sessionClient = .previewValue
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private struct ContentView: View {
    @State private var viewModel = VocabularyListViewModel(sessionID: "demo")

    var body: some View {
        Text("VocabularyFeature Example")
            .task { await viewModel.load() }
    }
}
