import SwiftUI

import DesignSystem
import DomainInterface

import SwiftUINavigation

public struct LearningLibraryView: View {
    @State private var viewModel: LearningLibraryViewModel

    public init(viewModel: LearningLibraryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                LearningLibraryLoadingView()
            case .success(let state):
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("학습 라이브러리")
                            .stageTypography(.listTitle)
                            .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                        LevelList(levels: state.levels, onLevelTapped: { viewModel.didTapLevel(id: $0) })
                    }
                }
                .background(DesignSystemAsset.background.swiftUIColor)
            case .error(let message):
                ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.onAppear() }
        .navigationDestination(item: $viewModel.destination.stageDetail) { detailVM in
            StageDetailView(viewModel: detailVM)
        }
    }
}
