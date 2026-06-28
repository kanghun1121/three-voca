import SwiftUI

import DesignSystem
import DomainInterface

struct MonthlyCalendarCard: View {
    let activities: [DailyActivity]
    let streakDays: Int

    @State private var viewModel = CalendarViewModel()

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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CalendarHeaderRow(
                year: viewModel.year,
                month: viewModel.month,
                isAtCurrentMonth: viewModel.isAtCurrentMonth,
                onPrevious: viewModel.previousMonth,
                onNext: viewModel.nextMonth,
                onToday: viewModel.goToToday
            )
            .padding(.bottom, 19)
            CalendarWeekdayHeader()
                .padding(.bottom, 6)
            CalendarGridSection(
                rows: viewModel.rows,
                activityMap: activityMap,
                today: viewModel.today,
                displayedDate: viewModel.displayedDate
            )
            CalendarFooterRow(streakDays: streakDays, isAtCurrentMonth: viewModel.isAtCurrentMonth)
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
