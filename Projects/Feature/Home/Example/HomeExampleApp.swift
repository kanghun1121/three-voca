import FeatureHome
import FeatureHomeTesting
import SwiftUI

@main
struct HomeExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(viewModel: HomeViewModel(repository: MockHomeRepository()))
            }
        }
    }
}
