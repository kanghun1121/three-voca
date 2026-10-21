import Foundation

import DomainInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class StageDetailViewModel {
    @CasePathable
    public enum Destination {
        case lessonDetail(LessonDetailViewModel)
    }

    var destination: Destination?

    /// 부모(LearningLibraryViewModel)가 이미 들고 있던 스냅샷으로 즉시 첫 페인트를 하고,
    /// 이후 스트림 구독으로 같은 id를 재도출해 라이브 갱신한다(세션 완료 후 pop-back 시 반영).
    private(set) var level: LevelSummary
    @ObservationIgnored private(set) var observationTask: Task<Void, Never>?
    private let levelID: String

    @ObservationIgnored @Dependency(\.learningLibraryRepository) private var learningLibraryRepository

    public init(level: LevelSummary) {
        self.level = level
        self.levelID = level.id
    }

    public func onAppear() async {
        guard observationTask == nil else { return }

        observationTask = Task {
            for await library in learningLibraryRepository.stream() {
                guard let updated = library.levels.first(where: { $0.id == self.levelID }) else { continue }
                self.level = updated
            }
        }
    }

    func didTapSession(id: String) {
        destination = .lessonDetail(LessonDetailViewModel(lessonID: id))
    }

    deinit {
        observationTask?.cancel()
    }
}
