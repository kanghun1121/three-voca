import SwiftUI

import DesignSystem

struct MonthlyCalendarCard: View {
    let viewModel: HomeViewModel

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var activityMap: [String: CalendarDayIntensity] {
        Dictionary(uniqueKeysWithValues: viewModel.activities.compactMap { activity -> (String, CalendarDayIntensity)? in
            let intensity: CalendarDayIntensity
            switch activity.sessionsCount {
            case 1:    intensity = .lv0
            case 2:    intensity = .lv1
            case 3:    intensity = .lv2
            default:   intensity = .lv3
            }
            return (activity.date, intensity)
        })
    }

    private var studiedDaysCount: Int {
        viewModel.calendarRows
            .flatMap { $0 }
            .filter { $0.isCurrentMonth }
            .filter { activityMap[Self.dateFormatter.string(from: $0.date)] != nil }
            .count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CalendarHeaderRow(
                year: viewModel.calendarYear,
                month: viewModel.calendarMonth,
                isAtCurrentMonth: viewModel.isCalendarAtCurrentMonth,
                onPrevious: viewModel.calendarPreviousMonth,
                onNext: viewModel.calendarNextMonth,
                onToday: viewModel.calendarGoToToday
            )
            .padding(.bottom, 16)
            CalendarWeekdayHeader()
                .padding(.bottom, 6)
            CalendarGridSection(rows: viewModel.calendarRows, activityMap: activityMap)
            CalendarLegendRow(studiedDaysCount: studiedDaysCount)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .background(DesignSystemAsset.white.swiftUIColor)
        .clipShape(.rect(cornerRadius: 26))
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .strokeBorder(DesignSystemAsset.borderSubtle.swiftUIColor, lineWidth: 1)
        }
        .shadow(
            color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.06),
            radius: 20,
            x: 0,
            y: 6
        )
    }
}
