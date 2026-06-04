import Dependencies
import Domain
import FeatureHome
import SwiftUI

@main
struct FiveVocaApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: withDependencies {
                    $0.homeClient = .liveValue
                    $0.sessionClient = .liveValue
                    $0.wordClient = .liveValue
                    $0.audioClient = .liveValue
                    $0.audioPlayerClient = .liveValue
                } operation: {
                    HomeViewModel()
                }
            )
        }
    }
}
