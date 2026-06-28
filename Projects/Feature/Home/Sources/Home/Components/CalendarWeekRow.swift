import SwiftUI

struct CalendarWeekRow: View {
    let days: [CalendarDay]
    let activityMap: [String: CalendarDayIntensity]

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days, id: \.date) { day in
                CalendarDayCell(kind: cellKind(for: day))
            }
        }
    }

    private func cellKind(for day: CalendarDay) -> CalendarDayCellKind {
        guard day.isCurrentMonth else { return .empty }
        let intensity = activityMap[Self.dateFormatter.string(from: day.date)]
        if day.isToday { return .today(day.dayNumber, intensity) }
        if day.isFuture { return .future(day.dayNumber) }
        if let intensity { return .studied(day.dayNumber, intensity) }
        return .notStudied(day.dayNumber)
    }
}
