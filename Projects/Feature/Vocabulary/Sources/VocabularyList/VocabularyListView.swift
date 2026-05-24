import SwiftUI

public struct VocabularyListView: View {
    @State private var viewModel: VocabularyListViewModel

    public init(viewModel: VocabularyListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let state):
                VocabularyListContentView(state: state)
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.load() }
        .navigationBarTitleDisplayMode(.inline)
    }
}
