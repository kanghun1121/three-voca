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

    // MARK: - Calendar

    let calendarToday: Date
    private(set) var calendarMonthOffset: Int = 0

    @ObservationIgnored @Dependency(\.homeClient) private var homeClient

    @CasePathable
    public enum Destination {
        case session(SessionDetailViewModel)
    }

    public init(
        destination: Destination? = nil,
        calendarToday: Date = Calendar.current.startOfDay(for: .now)
    ) {
        self.destination = destination
        self.calendarToday = calendarToday
    }

    // MARK: - Calendar computed

    private var cal: Calendar { .current }

    var calendarDisplayedDate: Date {
        cal.date(byAdding: .month, value: calendarMonthOffset, to: calendarToday) ?? calendarToday
    }

    var calendarYear: Int { cal.component(.year, from: calendarDisplayedDate) }
    var calendarMonth: Int { cal.component(.month, from: calendarDisplayedDate) }
    var isCalendarAtCurrentMonth: Bool { calendarMonthOffset == 0 }

    var calendarRows: [[Int?]] {
        let count = cal.range(of: .day, in: .month, for: calendarDisplayedDate)?.count ?? 30
        var comps = cal.dateComponents([.year, .month], from: calendarDisplayedDate)
        comps.day = 1
        let firstDow = cal.date(from: comps).map { cal.component(.weekday, from: $0) - 1 } ?? 0
        let cells: [Int?] = Array(repeating: nil, count: firstDow) + (1...count).map { Optional($0) }
        return stride(from: 0, to: cells.count, by: 7).map { start in
            let end = min(start + 7, cells.count)
            let row = Array(cells[start..<end])
            return row + Array(repeating: nil, count: 7 - row.count)
        }
    }

    // MARK: - Calendar actions

    func calendarPreviousMonth() { calendarMonthOffset -= 1 }

    func calendarNextMonth() {
        guard !isCalendarAtCurrentMonth else { return }
        calendarMonthOffset += 1
    }

    func calendarGoToToday() { calendarMonthOffset = 0 }

    // MARK: - Home actions

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
