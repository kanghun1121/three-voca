import SwiftUI

struct HomeContentView: View {
    let state: HomeViewState
    let expandedLevelIDs: Set<String>
    let onToggleLevel: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(state.levels) { level in
                    LevelCard(
                        viewState: level,
                        isExpanded: expandedLevelIDs.contains(level.id),
                        action: { onToggleLevel(level.id) }
                    )
                }
            }
            .padding()
        }
    }
}
