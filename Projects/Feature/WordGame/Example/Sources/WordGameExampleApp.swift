import SwiftUI

import Dependencies
import DomainInterface
import FeatureWordGame
import FeatureWordGameInterface

@main
struct WordGameExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                let viewModel = WordGameViewModel(words: Session.previewWords)
                WordGameView(viewModel: viewModel)
            }
        }
    }
}
