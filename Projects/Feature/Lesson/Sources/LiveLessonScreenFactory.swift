import SwiftUI

import FeatureLessonInterface

import Dependencies

public struct LiveLessonScreenFactory: LessonScreenFactory {
    public init() {}

    @MainActor
    public func makeLessonDetailScreen(lessonID: String) -> AnyView {
        AnyView(LessonDetailScreen(lessonID: lessonID))
    }

    @MainActor
    public func makeLearningLibraryScreen() -> AnyView {
        AnyView(LearningLibraryView(viewModel: LearningLibraryViewModel()))
    }
}

/// ViewModel 수명을 화면이 소유한다. 부모 body가 다시 평가돼도 상태가 초기화되지 않는다.
private struct LessonDetailScreen: View {
    @State private var viewModel: LessonDetailViewModel

    init(lessonID: String) {
        _viewModel = State(initialValue: LessonDetailViewModel(lessonID: lessonID))
    }

    var body: some View {
        LessonDetailView(viewModel: viewModel)
    }
}

extension LessonScreenFactoryKey: DependencyKey {
    public static let liveValue: any LessonScreenFactory = LiveLessonScreenFactory()
}
