import Foundation

import DomainInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class LearningLibraryViewModel {
    enum LearningLibraryUIState: Equatable {
        case loading
        case success(LearningLibrary)
        case error(String)
    }

    @CasePathable
    public enum Destination {
        case stageDetail(StageDetailViewModel)
    }

    var destination: Destination?

    private(set) var uiState: LearningLibraryUIState = .loading
    @ObservationIgnored private(set) var observationTask: Task<Void, Never>?

    @ObservationIgnored @Dependency(\.learningLibraryRepository) private var learningLibraryRepository

    public init() {}

    public func onAppear() async {
        guard observationTask == nil else { return }

        observationTask = Task {
            for await library in learningLibraryRepository.stream() {
                self.apply(library)
            }
        }
    }

    func didTapLevel(id: String) {
        guard case .success(let library) = uiState,
              let level = library.levels.first(where: { $0.id == id }),
              !level.isLocked else { return }
        destination = .stageDetail(StageDetailViewModel(level: level))
    }

    private func apply(_ library: LearningLibrary) {
        uiState = .success(library)
    }

    deinit {
        observationTask?.cancel()
    }
}
