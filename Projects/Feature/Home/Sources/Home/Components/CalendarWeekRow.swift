import SwiftUI

struct CalendarWeekRow: View {
    let days: [CalendarDay]
    let activityMap: [String: CalendarDayIntensity]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(days, id: \.date) { day in
                CalendarDayCell(kind: resolveCellKind(for: day))
            }
        }
    }

    private func resolveCellKind(for day: CalendarDay) -> CalendarDayCellKind {
        guard day.isCurrentMonth else { return .empty }
        let intensity = activityMap[day.date.calendarDateKey]
        if day.isToday { return .today(day.dayNumber, intensity) }
        if day.isFuture { return .future(day.dayNumber) }
        if let intensity { return .studied(day.dayNumber, intensity) }
        return .notStudied(day.dayNumber)
    }
}
