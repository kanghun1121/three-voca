import Foundation

import DomainInterface
import FeatureSession

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class HomeViewModel {
    private(set) var state: HomePresentationModel?
    private(set) var activities: [DailyActivity] = []
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?
    private(set) var expandedLevelIDs: Set<String> = []
    var destination: Destination?

    @ObservationIgnored @Dependency(\.homeClient) private var homeClient

    @CasePathable
    public enum Destination {
        case session(SessionDetailViewModel)
    }

    public init(destination: Destination? = nil) {
        self.destination = destination
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let overview = homeClient.fetchHomeOverview()
            async let heatmap = homeClient.fetchHeatmapData()
            let (library, fetched) = try await (overview, heatmap)
            activities = fetched
            state = library.toHomePresentationModel(activities: fetched)
            if expandedLevelIDs.isEmpty, let activeID = state?.levels.first(where: { $0.status == .active })?.id {
                expandedLevelIDs.insert(activeID)
            }
        } catch {
            errorMessage = "홈 정보를 불러오지 못했습니다."
        }
    }

    public func levelTapped(id: String) {
        if expandedLevelIDs.contains(id) {
            expandedLevelIDs.remove(id)
        } else {
            expandedLevelIDs.insert(id)
        }
    }

    public func sessionTapped(id: Int) {
        destination = .session(SessionDetailViewModel(sessionID: String(id)))
    }
}
