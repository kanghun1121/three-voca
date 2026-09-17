import XCTest

import DomainInterface
@testable import FeatureLesson

import Dependencies

@MainActor
final class LearningLibraryViewModelTests: XCTestCase {
    func test_초기값은_loading이다() {
        let vm = withDependencies {
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
        } operation: {
            LearningLibraryViewModel()
        }

        XCTAssertEqual(vm.uiState, .loading)
    }

    func test_onAppear_성공시_uiState가_success로_채워진다() async {
        let library = makeLibrary(levels: [
            makeLevel(id: "level_1", completedLessons: 5, totalLessons: 5), // completed
            makeLevel(id: "level_2", completedLessons: 2, totalLessons: 5), // active
            makeLevel(id: "level_3", completedLessons: 0, totalLessons: 5), // notStarted
        ])
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = { makeStream([library]) }
        } operation: {
            LearningLibraryViewModel()
        }

        await vm.onAppear()
        await vm.observationTask?.value

        XCTAssertEqual(vm.uiState, .success(library))
    }

    func test_didTapLevel_잠기지_않은_단계면_stageDetail_목적지를_설정한다() async {
        let library = makeLibrary(levels: [
            makeLevel(id: "level_2", completedLessons: 2, totalLessons: 5),
        ])
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = { makeStream([library]) }
        } operation: {
            LearningLibraryViewModel()
        }
        await vm.onAppear()
        await vm.observationTask?.value

        vm.didTapLevel(id: "level_2")

        guard case .stageDetail(let detailVM) = vm.destination else {
            XCTFail("destination이 .stageDetail이어야 합니다. 실제: \(String(describing: vm.destination))")
            return
        }
        XCTAssertEqual(detailVM.level.id, "level_2")
    }

    func test_didTapLevel_잠긴_단계면_아무_동작도_하지_않는다() async {
        let library = makeLibrary(levels: [
            makeLevel(id: "level_5", completedLessons: 0, totalLessons: 0), // 레슨 0개 = 잠김
        ])
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = { makeStream([library]) }
        } operation: {
            LearningLibraryViewModel()
        }
        await vm.onAppear()
        await vm.observationTask?.value

        vm.didTapLevel(id: "level_5")

        XCTAssertNil(vm.destination)
    }

    func test_스트림이_값을_안_주면_uiState는_loading에_머무른다() async {
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = { makeStream([]) }
        } operation: {
            LearningLibraryViewModel()
        }

        await vm.onAppear()
        await vm.observationTask?.value

        XCTAssertEqual(vm.uiState, .loading)
    }

    func test_onAppear_2회_호출해도_구독_스트림은_1번만_생성된다() async {
        let counter = CallCounter()
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = {
                counter.increment()
                return makeStream([.previewFixture])
            }
        } operation: {
            LearningLibraryViewModel()
        }

        await vm.onAppear()
        await vm.observationTask?.value
        await vm.onAppear()
        await vm.observationTask?.value

        XCTAssertEqual(counter.value, 1)
    }

    func test_스트림이_값을_2번_주면_최신_값으로_갱신된다() async {
        let first = makeLibrary(levels: [
            makeLevel(id: "level_1", completedLessons: 2, totalLessons: 5),
        ])
        let second = makeLibrary(levels: [
            makeLevel(id: "level_2", completedLessons: 3, totalLessons: 5),
        ])
        let vm = withDependencies {
            $0.learningLibraryRepository.stream = { makeStream([first, second]) }
        } operation: {
            LearningLibraryViewModel()
        }

        await vm.onAppear()
        await vm.observationTask?.value

        XCTAssertEqual(vm.uiState, .success(second))
    }
}

/// 테스트 전용 — `stream`이 몇 번 호출됐는지 세기 위한 카운터.
private final class CallCounter: @unchecked Sendable {
    private(set) var value = 0
    func increment() { value += 1 }
}

private func makeStream(_ values: [LearningLibrary]) -> AsyncStream<LearningLibrary> {
    AsyncStream { continuation in
        for value in values { continuation.yield(value) }
        continuation.finish()
    }
}

private func makeLibrary(levels: [LevelSummary]) -> LearningLibrary {
    LearningLibrary(levels: levels)
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
