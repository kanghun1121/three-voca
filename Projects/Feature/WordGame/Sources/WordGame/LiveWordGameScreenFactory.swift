import SwiftUI

import FeatureWordGameInterface

import Dependencies

public struct LiveWordGameScreenFactory: WordGameScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(lessonID: String) -> AnyView {
        AnyView(WordGameScreen(lessonID: lessonID))
    }
}

/// ViewModel 수명을 화면이 소유한다. 부모 body가 다시 평가돼도 상태가 초기화되지 않는다.
private struct WordGameScreen: View {
    @State private var viewModel: WordGameViewModel

    init(lessonID: String) {
        _viewModel = State(initialValue: WordGameViewModel(lessonID: lessonID))
    }

    var body: some View {
        WordGameView(viewModel: viewModel)
    }
}

extension WordGameScreenFactoryKey: DependencyKey {
    public static let liveValue: any WordGameScreenFactory = LiveWordGameScreenFactory()
}
