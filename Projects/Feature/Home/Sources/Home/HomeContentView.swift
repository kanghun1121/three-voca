import SwiftUI

import DomainInterface
import DesignSystem
import Dependencies

struct HomeContentView: View {
    let state: HomePresentationModel
    let heatmapData: [DailyActivity]
    let expandedLevelIDs: Set<String>
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeGreetingHeader()
                HeatmapCard(activities: heatmapData)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 22)
                HomeLevelList(
                    levels: state.levels,
                    expandedLevelIDs: expandedLevelIDs,
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
        state: VocabularyLibrary.previewFixture.toHomePresentationModel(),
        heatmapData: DailyActivity.previewFixture,
        expandedLevelIDs: [],
        onLevelTapped: { _ in },
        onSessionTapped: { _ in }
    )
}
