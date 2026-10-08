import SwiftUI

import FeatureWordInterface

import Dependencies

public struct LiveWordListScreenFactory: WordListScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(lessonID: String) -> AnyView {
        AnyView(WordListScreen(lessonID: lessonID))
    }
}

/// ViewModel 수명을 화면이 소유한다. 부모 body가 다시 평가돼도 상태가 초기화되지 않는다.
private struct WordListScreen: View {
    @State private var viewModel: WordListViewModel

    init(lessonID: String) {
        _viewModel = State(initialValue: WordListViewModel(lessonID: lessonID))
    }

    var body: some View {
        WordListView(viewModel: viewModel)
    }
}

extension WordListScreenFactoryKey: DependencyKey {
    public static let liveValue: any WordListScreenFactory = LiveWordListScreenFactory()
}
