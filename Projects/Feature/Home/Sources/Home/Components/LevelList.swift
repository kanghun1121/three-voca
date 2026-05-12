import SwiftUI

struct LevelList: View {
    let levels: [LevelCardViewState]
    let expandedLevelIDs: Set<String>
    let onToggleLevel: (String) -> Void

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(levels) { level in
                LevelCard(
                    viewState: level,
                    isExpanded: expandedLevelIDs.contains(level.id)
                ) { onToggleLevel(level.id) }
            }
        }
        .padding(.horizontal)
    }
}
