import FeatureVocabulary
import SwiftUI
import SwiftUINavigation

public struct SessionDetailView: View {
    @Bindable private var viewModel: SessionDetailViewModel

    public init(viewModel: SessionDetailViewModel) {
        _viewModel = Bindable(viewModel)
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let state):
                SessionDetailContentView(
                    state: state,
                    onVocabularyListTapped: viewModel.vocabularyListTapped
                )
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.load() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $viewModel.destination.vocabularyList) { vocabularyListVM in
            VocabularyListView(viewModel: vocabularyListVM)
        }
    }
}
