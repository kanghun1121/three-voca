import SwiftUI

import FeatureHome

import Dependencies

@main
struct HomeExampleApp: App {
    init() {
        prepareDependencies {
            $0.getHomeOverviewUseCase = .previewValue
            $0.getHeatmapDataUseCase = .previewValue
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
