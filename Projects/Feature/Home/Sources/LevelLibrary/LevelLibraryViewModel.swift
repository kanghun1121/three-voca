import Foundation

import DomainInterface
import FeatureSession

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class LevelLibraryViewModel {
    private(set) var state: VocabularyLibrary?
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?
    private(set) var expandedLevelIDs: Set<String> = []
    var destination: Destination?

    @ObservationIgnored @Dependency(\.getHomeOverviewUseCase) private var getHomeOverviewUseCase

    @CasePathable
    public enum Destination {
        case session(SessionDetailViewModel)
    }

    public init() {}

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let library = try await getHomeOverviewUseCase.execute()
            state = library
            if expandedLevelIDs.isEmpty, let activeID = library.levels.first(where: { $0.status == .active })?.id {
                expandedLevelIDs.insert(activeID)
            }
        } catch {
            errorMessage = "레벨 정보를 불러오지 못했습니다."
        }
    }

    func levelTapped(id: String) {
        if expandedLevelIDs.contains(id) {
            expandedLevelIDs.remove(id)
        } else {
            expandedLevelIDs.insert(id)
        }
    }

    func sessionTapped(id: String) {
        destination = .session(SessionDetailViewModel(sessionID: id))
    }
}
