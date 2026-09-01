import Foundation

enum HomeDayState {
    case today([DayRecord])
    case past([DayRecord])
    case empty(isFuture: Bool)

    /// 우선순위 고정: 오늘 여부를 최우선으로 판정한다 — 오늘 기록이 0개여도 반드시 `.today`를 반환해야
    /// 핸드오프 §5("오늘 세션이 없으면 CTA만 노출")가 지켜지고, `.empty`로 새는 회귀를 막을 수 있다.
    static func resolve(
        selectedDate: Date,
        today: Date,
        recordsByDate: [Date: [DayRecord]],
        calendar: Calendar
    ) -> HomeDayState {
        let dayStart = calendar.startOfDay(for: selectedDate)
        let records = recordsByDate[dayStart] ?? []
        let isToday = calendar.isDate(selectedDate, inSameDayAs: today)
        let isFuture = dayStart > today

        if isToday { return .today(records) }
        if isFuture { return .empty(isFuture: true) }
        return records.isEmpty ? .empty(isFuture: false) : .past(records)
    }

    var recordCount: Int {
        switch self {
        case .today(let records), .past(let records): records.count
        case .empty: 0
        }
    }
}
