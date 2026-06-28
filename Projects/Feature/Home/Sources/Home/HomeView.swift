import SwiftUI

import DesignSystem
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
                        activities: viewModel.activities,
                        expandedLevelIDs: viewModel.expandedLevelIDs,
                        onLevelTapped: { viewModel.levelTapped(id: $0) },
                        onSessionTapped: { viewModel.sessionTapped(id: $0) }
                    )
                } else if viewModel.isLoading {
                    HomeLoadingView()
                } else if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HomeLoadingView()
                }
            }
            .animation(.easeInOut(duration: 0.15), value: viewModel.state == nil)
            .task { await viewModel.load() }
            .navigationDestination(item: $viewModel.destination.session) { detailVM in
                SessionDetailView(viewModel: detailVM)
            }
        }
        .tint(DesignSystemAsset.fgStrong.swiftUIColor)
        .toolbar(viewModel.destination != nil ? .hidden : .visible, for: .tabBar)
    }
}

#Preview("홈") {
    HomeView(viewModel: HomeViewModel())
}

#Preview("로딩") {
    HomeLoadingView()
}
