import SwiftUI

import DesignSystem
import FeatureSession

import SwiftUINavigation

struct LevelLibraryView: View {
    @State private var viewModel: LevelLibraryViewModel

    init(viewModel: LevelLibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if let state = viewModel.state {
                ScrollView {
                    HomeLevelList(
                        levels: state.levels,
                        expandedLevelIDs: viewModel.expandedLevelIDs,
                        onLevelTapped: { viewModel.levelTapped(id: $0) },
                        onSessionTapped: { viewModel.sessionTapped(id: $0) }
                    )
                }
                .background(DesignSystemAsset.background.swiftUIColor)
            } else if viewModel.isLoading {
                HomeLoadingView()
            } else if let message = viewModel.errorMessage {
                ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
            } else {
                HomeLoadingView()
            }
        }
        .navigationTitle("학습 라이브러리")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .navigationDestination(item: $viewModel.destination.session) { detailVM in
            SessionDetailView(viewModel: detailVM)
        }
    }
}
