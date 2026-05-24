import SwiftUI

public struct SessionDetailView: View {
    @State private var viewModel: SessionDetailViewModel

    public init(viewModel: SessionDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let state):
                SessionDetailContentView(state: state)
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
