import SwiftUI

import DesignSystem

import SwiftUINavigation

public struct MultipleChoiceGameView: View {
    @Bindable private var viewModel: MultipleChoiceViewModel

    public init(viewModel: MultipleChoiceViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            GameBackground()

            switch viewModel.viewState {
            case .active, .pendingReveal, .revealed:
                if let word = viewModel.currentWord {
                    MultipleChoiceActivePhaseView(
                        word: word,
                        choices: viewModel.choices,
                        viewState: viewModel.viewState,
                        onDismiss: viewModel.closeButtonTapped,
                        onChoiceTap: viewModel.choiceTapped
                    )
                }

            case .completed:
                MultipleChoiceCompletedView()
            }
        }
        .onAppear { viewModel.load() }
        .toolbar(.hidden, for: .navigationBar)
        .alert($viewModel.destination.alert) { action in
            viewModel.alertButtonTapped(action)
        }
    }
}
