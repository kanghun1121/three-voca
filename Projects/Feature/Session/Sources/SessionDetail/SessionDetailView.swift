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
