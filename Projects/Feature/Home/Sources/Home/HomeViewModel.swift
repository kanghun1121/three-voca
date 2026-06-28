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
    private(set) var expandedLevelID: String?
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
            if expandedLevelID == nil {
                expandedLevelID = state?.levels.first(where: { $0.status == .active })?.id
            }
        } catch {
            errorMessage = "홈 정보를 불러오지 못했습니다."
        }
    }

    // single-open 아코디언: 같은 카드 탭 시 접힘, 다른 카드 탭 시 교체
    public func levelTapped(id: String) {
        expandedLevelID = expandedLevelID == id ? nil : id
    }

    public func sessionTapped(id: Int) {
        destination = .session(SessionDetailViewModel(sessionID: String(id)))
    }
}
