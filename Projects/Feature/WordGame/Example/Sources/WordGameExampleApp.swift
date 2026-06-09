import SwiftUI

import FeatureWordGame

import Dependencies

@main
struct WordGameExampleApp: App {
    init() {
        prepareDependencies {
            $0.sessionClient = .previewValue
        }
    }

    var body: some Scene {
        WindowGroup {
            ExampleRootView()
        }
    }
}

struct ExampleRootView: View {
    @State private var destination: WordGameViewModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Recognition 부터") {
                    destination = WordGameViewModel(sessionID: "demo", startingFrom: .recognition)
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
