import SwiftUI

import DesignSystem

import SwiftUINavigation

public struct StageDetailView: View {
    @State private var viewModel: StageDetailViewModel

    public init(viewModel: StageDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                StageHeroSection(level: viewModel.level)
                SessionListSection(
                    lessons: viewModel.level.lessons,
                    level: viewModel.level.level,
                    onSessionTapped: { viewModel.didTapSession(id: $0) }
                )
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
        .background(DesignSystemAsset.background.swiftUIColor)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.onAppear() }
        .navigationDestination(item: $viewModel.destination.lessonDetail) { detailVM in
            LessonDetailView(viewModel: detailVM)
        }
    }
}
