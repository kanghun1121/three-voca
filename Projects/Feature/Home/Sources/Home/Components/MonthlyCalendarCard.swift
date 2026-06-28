import SwiftUI

import DesignSystem
import DomainInterface

struct MonthlyCalendarCard: View {
    let activities: [DailyActivity]
    let streakDays: Int

    @State private var monthOffset = 0

    private let cal = Calendar.current

    private var today: Date { cal.startOfDay(for: Date.now) }

    private var displayedDate: Date {
        cal.date(byAdding: .month, value: monthOffset, to: today) ?? today
    }

    private var year: Int { cal.component(.year, from: displayedDate) }
    private var month: Int { cal.component(.month, from: displayedDate) }

    private var daysInMonth: Int {
        cal.range(of: .day, in: .month, for: displayedDate)?.count ?? 30
    }

    private var firstDow: Int {
        var comps = cal.dateComponents([.year, .month], from: displayedDate)
        comps.day = 1
        guard let firstDay = cal.date(from: comps) else { return 0 }
        return cal.component(.weekday, from: firstDay) - 1
    }

    private var activityMap: [String: CalendarDayIntensity] {
        Dictionary(uniqueKeysWithValues: activities.compactMap { activity -> (String, CalendarDayIntensity)? in
            let intensity: CalendarDayIntensity
            switch activity.sessionsCount {
            case 1:    intensity = .light
            case 2:    intensity = .mid
            default:   intensity = .full
            }
            return (activity.date, intensity)
        })
    }

    private var cells: [Int?] {
        Array(repeating: nil, count: firstDow) + (1...daysInMonth).map { Optional($0) }
    }

    private var rows: [[Int?]] {
        stride(from: 0, to: cells.count, by: 7).map { start in
            let end = min(start + 7, cells.count)
            let row = Array(cells[start..<end])
            return row + Array(repeating: nil, count: 7 - row.count)
        }
    }

    private var isAtCurrentMonth: Bool { monthOffset == 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CalendarHeaderRow(
                year: year,
                month: month,
                isAtCurrentMonth: isAtCurrentMonth,
                onPrevious: { monthOffset -= 1 },
                onNext: { monthOffset += 1 }
            )
            .padding(.bottom, 19)
            CalendarWeekdayHeader()
                .padding(.bottom, 6)
            CalendarGridSection(
                rows: rows,
                activityMap: activityMap,
                today: today,
                displayedDate: displayedDate
            )
            CalendarFooterRow(
                streakDays: streakDays,
                isAtCurrentMonth: isAtCurrentMonth,
                onToday: { monthOffset = 0 }
            )
            .padding(.top, 17)
        }
        .padding(.horizontal, 16)
        .padding(.top, 17)
        .padding(.bottom, 15)
        .background(DesignSystemAsset.white.swiftUIColor)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(
            color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.06),
            radius: 20,
            x: 0,
            y: 6
        )
    }
}

#Preview {
    MonthlyCalendarCard(
        activities: DailyActivity.previewFixture,
        streakDays: 5
    )
    .padding()
}
