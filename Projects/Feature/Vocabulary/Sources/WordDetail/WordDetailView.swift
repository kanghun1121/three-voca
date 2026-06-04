import SwiftUI

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel

    public init(viewModel: WordDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.wordIDs.indices, id: \.self) { index in
                WordDetailPageView(viewState: viewModel.viewStates[index])
                    .tag(index)
                    .task { await viewModel.requestIfNeeded(at: index) }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(viewModel.currentIndex + 1)/\(viewModel.wordIDs.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?

    var body: some View {
        switch viewState {
        case .loaded(let state):
            WordDetailContentView(state: state)
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
