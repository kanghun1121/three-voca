import SwiftUI

public struct SessionDetailView: View {
    @State private var viewModel: SessionDetailViewModel

    public init(viewModel: SessionDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            if let state = viewModel.state {
                SessionDetailContentView(state: state)
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview("학습 기록 있음") {
    NavigationStack {
        SessionDetailContentView(state: previewViewState(withRecord: true))
    }
}

#Preview("학습 기록 없음") {
    NavigationStack {
        SessionDetailContentView(state: previewViewState(withRecord: false))
    }
}

private func previewViewState(withRecord: Bool) -> SessionDetailViewState {
    SessionDetailViewState(
        levelHeader: "LEVEL 1 · SESSION 2",
        title: "3개 단어",
        subtitle: "약 15분 소요 · A1-A2 수준",
        record: withRecord ? SessionDetailViewState.Record(
            firstCompletedDateText: "2026.05.01",
            lastStudiedRelativeText: "1일 전",
            reviewCountText: "3회",
            averageAccuracyText: "87%"
        ) : nil,
        wordsSectionTitle: "이번 세션의 단어 (3)",
        previewItems: [
            SessionDetailViewState.WordPreview(
                id: "1",
                term: "ambiguous",
                primaryMeaning: "모호한, 애매한"
            ),
            SessionDetailViewState.WordPreview(
                id: "2",
                term: "persevere",
                primaryMeaning: "끈기 있게 계속하다"
            ),
            SessionDetailViewState.WordPreview(
                id: "3",
                term: "eloquent",
                primaryMeaning: "유창한"
            ),
        ],
        moreText: nil
    )
}
#endif
