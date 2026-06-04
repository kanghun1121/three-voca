import DesignSystem
import SwiftUI

public struct VocabularyListView: View {
    @Bindable private var viewModel: VocabularyListViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: VocabularyListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("단어 목록 불러오는 중")
            case .loaded(let state):
                VocabularyListContentView(state: state, onWordTapped: viewModel.didTapWord)
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.load() }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: dismiss.callAsFunction) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                }
            }
        }
        .navigationDestination(item: $viewModel.destination.wordDetail) { wordDetailVM in
            WordDetailView(viewModel: wordDetailVM)
        }
    }
}
