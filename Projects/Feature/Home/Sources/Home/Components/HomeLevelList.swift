import SwiftUI

import DesignSystem

struct HomeLevelList: View {
    let levels: [LevelCardPresentationModel]
    let expandedLevelIDs: Set<String>
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        LazyVStack(spacing: 14) {
            ForEach(levels) { level in
                LevelCard(
                    presentationModel: level,
                    isExpanded: expandedLevelIDs.contains(level.id)
                ) {
                    onLevelTapped(level.id)
                } onSessionTapped: { id in
                    onSessionTapped(id)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 24)
    }
}
