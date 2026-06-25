import SwiftUI

import DesignSystem

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WordDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.wordIDs.indices, id: \.self) { index in
                WordDetailPageView(viewState: viewModel.viewStates[index]) { term in
                    Task { await viewModel.didTapPronunciationButton(term: term) }
                }
                .tag(index)
                .task { await viewModel.requestIfNeeded(at: index) }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(DesignSystemAsset.bg.swiftUIColor)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(DesignSystemAsset.bg.swiftUIColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("뒤로", systemImage: "chevron.left", action: dismiss.callAsFunction)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            }
        }
    }
}

private struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?
    let onPronunciationTapped: (String) -> Void

    var body: some View {
        switch viewState {
        case .loaded(let state):
            WordDetailContentView(state: state, onPronunciationTapped: onPronunciationTapped)
        case .error(let message):
            Text(message)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading, nil:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("단어 정보 불러오는 중")
        }
    }
}
