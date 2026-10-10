import SwiftUI

import DesignSystem
import Dependencies

public struct WordListView: View {
    @Bindable private var viewModel: WordListViewModel

    public init(viewModel: WordListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                WordListSkeletonView()
            case .loaded(let state):
                WordListContentView(
                    state: state,
                    learningHistory: viewModel.learningHistory,
                    onWordTapped: viewModel.didTapWord
                )
            case .error(let message):
                Text(message)
                    .foregroundStyle(DesignSystemColor.Foreground.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.load() }
        .navigationDestination(item: $viewModel.destination.wordDetail) { wordDetailVM in
            WordDetailView(viewModel: wordDetailVM)
        }
    }
}

#Preview("로딩") {
    let vm = withDependencies {
        $0.loadLessonWordsUseCase = .previewLoading
    } operation: {
        WordListViewModel(lessonID: "preview")
    }
    NavigationStack {
        WordListView(viewModel: vm)
    }
}
