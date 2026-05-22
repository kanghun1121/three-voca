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
            HomeView(viewModel: HomeViewModel())
        }
    }
}
