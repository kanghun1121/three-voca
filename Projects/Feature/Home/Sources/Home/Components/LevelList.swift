import SwiftUI

struct LevelList: View {
    let levels: [LevelCardViewState]
    let expandedLevelIDs: Set<String>
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(levels) { level in
                LevelCard(
                    viewState: level,
                    isExpanded: expandedLevelIDs.contains(level.id),
                    action: { onLevelTapped(level.id) },
                    onSessionTapped: onSessionTapped
                )
            }
        }
        .padding(.horizontal)
    }
}
