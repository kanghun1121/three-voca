import SwiftUI

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel

    public init(viewModel: WordDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.wordIDs.indices, id: \.self) { index in
                pageContent(at: index)
                    .tag(index)
                    .task { await viewModel.loadIfNeeded(at: index) }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func pageContent(at index: Int) -> some View {
        switch viewModel.viewStates[index] {
        case .loaded(let state):
            WordDetailContentView(state: state)
        case .error(let message):
            Text(message)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading, nil:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
