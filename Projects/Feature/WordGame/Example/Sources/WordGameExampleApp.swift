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
            WordGameView(viewModel: WordGameViewModel(sessionID: "demo"))
        }
    }
}
