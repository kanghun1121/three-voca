import Dependencies
import FeatureSession
import SwiftUI

@main
struct VocaExampleApp: App {
    init() {
        prepareDependencies {
            $0.sessionClient = .previewValue
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SessionDetailView(viewModel: SessionDetailViewModel(sessionID: "demo"))
            }
        }
    }
}
