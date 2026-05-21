import Dependencies
import FeatureHome
import SwiftUI

@main
struct HomeExampleApp: App {
    init() {
        prepareDependencies {
            $0.homeClient = .previewValue
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(viewModel: HomeViewModel())
            }
        }
    }
}
