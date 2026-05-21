import Dependencies
import Domain
import FeatureHome
import FeatureVoca
import SwiftUI

@main
struct FiveVocaApp: App {
    var body: some Scene {
        WindowGroup {
            SessionDetailView(viewModel: withDependencies {
                $0.sessionClient = .liveValue
            } operation: {
                SessionDetailViewModel(sessionID: "15")
            })
        }
    }
}
