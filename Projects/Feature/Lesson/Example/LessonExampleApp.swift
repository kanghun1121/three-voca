import SwiftUI

import FeatureLesson

import Dependencies

@main
struct LessonExampleApp: App {
    init() {
        prepareDependencies {
            $0.loadLessonDetailUseCase.execute = { id in (lesson: .preview(id: id), audioReady: Task {}) }
            $0.learningHistoryRepository.stream = { _ in
                AsyncStream { continuation in
                    continuation.yield(.preview)
                    continuation.finish()
                }
            }
            // [TestDependencyKey 제거] previewValue도 unimplemented가 되어 인라인
            $0.learningLibraryRepository = LearningLibraryRepository(
                stream: {
                    AsyncStream { continuation in
                        continuation.yield(.previewFixture)
                        continuation.finish()
                    }
                },
                refresh: {}
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LearningLibraryView(viewModel: LearningLibraryViewModel())
            }
        }
    }
}
