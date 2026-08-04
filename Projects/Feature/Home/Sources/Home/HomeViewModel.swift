import Foundation

import UseCaseInterface
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

    let calendarToday: Date
    private(set) var calendarMonthOffset: Int = 0

    @ObservationIgnored @Dependency(\.homeClient) private var homeClient

    private var cal: Calendar { .current }

    var calendarDisplayedDate: Date {
        cal.date(byAdding: .month, value: calendarMonthOffset, to: calendarToday) ?? calendarToday
    }

    var calendarYear: Int { cal.component(.year, from: calendarDisplayedDate) }
    var calendarMonth: Int { cal.component(.month, from: calendarDisplayedDate) }
    var isCalendarAtCurrentMonth: Bool { calendarMonthOffset == 0 }

    var calendarRows: [[CalendarDay]] {
        let period = cal.monthlyCalendarPeriod(for: calendarDisplayedDate)
        let days = calendarDays(for: period)
        return stride(from: 0, to: days.count, by: 7).map { start in
            Array(days[start..<min(start + 7, days.count)])
        }
    }

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

    private func calendarDays(for period: DateInterval) -> [CalendarDay] {
        let displayedComps = cal.dateComponents([.year, .month], from: calendarDisplayedDate)
        var days: [CalendarDay] = []
        var current = period.start
        while current < period.end {
            let comps = cal.dateComponents([.year, .month], from: current)
            let isCurrentMonth = comps.year == displayedComps.year && comps.month == displayedComps.month
            days.append(CalendarDay(
                date: current,
                dayNumber: cal.component(.day, from: current),
                isCurrentMonth: isCurrentMonth,
                isToday: cal.isDate(current, inSameDayAs: calendarToday),
                isFuture: cal.startOfDay(for: current) > calendarToday
            ))
            guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return days
    }

    func calendarPreviousMonth() {
        calendarMonthOffset -= 1
    }

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
            state = library.toHomePresentationModel()
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
