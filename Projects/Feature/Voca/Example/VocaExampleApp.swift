import SwiftUI

import FeatureVoca
import FeatureVocaTesting

@main
struct VocaExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SessionDetailView(viewModel: SessionDetailViewModel(sessionID: "demo", repository: MockSessionRepository()))
            }
        }
    }
}
