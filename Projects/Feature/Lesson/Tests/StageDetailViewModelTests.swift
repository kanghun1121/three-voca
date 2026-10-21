import XCTest

import DomainInterface
@testable import FeatureLesson

import Dependencies

@MainActor
final class StageDetailViewModelTests: XCTestCase {
    func test_init_직후_level이_초기값과_일치한다() {
        let level = makeLevel(id: "level_1", completedLessons: 2, totalLessons: 5)
        let vm = withDependencies {
            $0.learningLibraryRepository = .previewValue
        } operation: {
            StageDetailViewModel(level: level)
        }

        XCTAssertEqual(vm.level, level)
    }

    func test_onAppear_스트림이_같은_id의_갱신된_level을_주면_라이브_반영된다() async {
        let initial = makeLevel(id: "level_1", completedLessons: 2, totalLessons: 5)
        let updated = makeLevel(id: "level_1", completedLessons: 3, totalLessons: 5)
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = {
                makeStream([LearningLibrary(levels: [updated])])
            }
        } operation: {
            StageDetailViewModel(level: initial)
        }

        await vm.onAppear()
        await vm.observationTask?.value

        XCTAssertEqual(vm.level, updated)
    }

    func test_onAppear_스트림에_같은_id가_없으면_기존_level을_유지한다() async {
        let initial = makeLevel(id: "level_1", completedLessons: 2, totalLessons: 5)
        let other = makeLevel(id: "level_2", completedLessons: 1, totalLessons: 5)
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = {
                makeStream([LearningLibrary(levels: [other])])
            }
        } operation: {
            StageDetailViewModel(level: initial)
        }

        await vm.onAppear()
        await vm.observationTask?.value

        XCTAssertEqual(vm.level, initial)
    }

    func test_didTapSession_lessonDetail_목적지를_설정한다() {
        let level = makeLevel(id: "level_1", completedLessons: 2, totalLessons: 5)
        let vm = withDependencies {
            $0.learningLibraryRepository = .previewValue
        } operation: {
            StageDetailViewModel(level: level)
        }

        vm.didTapSession(id: "lesson_1")

        guard case .lessonDetail = vm.destination else {
            XCTFail("destination이 .lessonDetail이어야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }
    }
}

private func makeStream(_ values: [LearningLibrary]) -> AsyncStream<LearningLibrary> {
    AsyncStream { continuation in
        for value in values { continuation.yield(value) }
        continuation.finish()
    }
}

private func makeLevel(
    id: String,
    completedLessons: Int,
    totalLessons: Int
) -> LevelSummary {
    LevelSummary(
        id: id,
        level: 1,
        name: "Level",
        difficulty: "A1",
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        lessons: []
    )
}
