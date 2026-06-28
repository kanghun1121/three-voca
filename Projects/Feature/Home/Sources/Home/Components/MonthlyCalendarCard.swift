import SwiftUI

import DesignSystem

struct MonthlyCalendarCard: View {
    let viewModel: HomeViewModel
    let streakDays: Int

    private var activityMap: [String: CalendarDayIntensity] {
        Dictionary(uniqueKeysWithValues: viewModel.activities.compactMap { activity -> (String, CalendarDayIntensity)? in
            let intensity: CalendarDayIntensity
            switch activity.sessionsCount {
            case 1:    intensity = .light
            case 2:    intensity = .mid
            default:   intensity = .full
            }
            return (activity.date, intensity)
        })
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
            .padding(.bottom, 19)
            CalendarWeekdayHeader()
                .padding(.bottom, 6)
            CalendarGridSection(
                rows: viewModel.calendarRows,
                activityMap: activityMap,
                today: viewModel.calendarToday,
                displayedDate: viewModel.calendarDisplayedDate
            )
            CalendarFooterRow(streakDays: streakDays, isAtCurrentMonth: viewModel.isCalendarAtCurrentMonth)
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
