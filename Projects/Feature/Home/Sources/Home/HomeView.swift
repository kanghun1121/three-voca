import SwiftUI

import FeatureSession

import SwiftUINavigation

public struct HomeView: View {
    @State private var viewModel: HomeViewModel

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if let state = viewModel.state {
                    HomeContentView(
                        state: state,
                        heatmapData: viewModel.heatmapData,
                        expandedLevelID: viewModel.expandedLevelID,
                        onLevelTapped: { viewModel.levelTapped(id: $0) },
                        onSessionTapped: { viewModel.sessionTapped(id: $0) }
                    )
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .task { await viewModel.load() }
            .navigationDestination(item: $viewModel.destination.session) { detailVM in
                SessionDetailView(viewModel: detailVM)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
