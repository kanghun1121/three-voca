import SwiftUI

import DesignSystem
import DomainInterface

struct HomeContentView: View {
    let state: HomePresentationModel
    let activities: [DailyActivity]
    let expandedLevelID: String?
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeGreetingHeader()
                MonthlyCalendarCard(
                    activities: activities,
                    streakDays: state.streakDays
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
                HomeLevelList(
                    levels: state.levels,
                    expandedLevelID: expandedLevelID,
                    onLevelTapped: onLevelTapped,
                    onSessionTapped: onSessionTapped
                )
            }
        }
        .background(DesignSystemAsset.bg.swiftUIColor)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    HomeContentView(
        state: VocabularyLibrary.previewFixture.toHomePresentationModel(activities: DailyActivity.previewFixture),
        activities: DailyActivity.previewFixture,
        expandedLevelID: nil,
        onLevelTapped: { _ in },
        onSessionTapped: { _ in }
    )
}
