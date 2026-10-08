import SwiftUI

import DomainInterface
import FeatureWordGameInterface
import FeatureWordInterface

import Dependencies
import SwiftUINavigation

public struct LessonDetailView: View {
    @Bindable private var viewModel: LessonDetailViewModel
    @Dependency(\.wordListScreenFactory) private var wordListScreenFactory
    @Dependency(\.wordGameScreenFactory) private var wordGameScreenFactory

    public init(viewModel: LessonDetailViewModel) {
        _viewModel = Bindable(viewModel)
    }

    public var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                LessonDetailContentView(
                    state: .preview(id: "placeholder"),
                    learningHistory: .preview,
                    onGameTapped: {},
                    onWordListTapped: {}
                )
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
            case .loaded(let state):
                LessonDetailContentView(
                    state: state,
                    learningHistory: viewModel.learningHistory,
                    onGameTapped: viewModel.didTapGame,
                    onWordListTapped: viewModel.didTapWordList
                )
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.onAppear() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $viewModel.destination.wordList) { lessonID in
            wordListScreenFactory.makeScreen(lessonID: lessonID.wrappedValue)
        }
        .navigationDestination(item: $viewModel.destination.wordGame) { lessonID in
            wordGameScreenFactory.makeScreen(lessonID: lessonID.wrappedValue)
        }
    }
}
