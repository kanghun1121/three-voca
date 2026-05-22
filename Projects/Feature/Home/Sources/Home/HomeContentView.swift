import SwiftUI

struct HomeContentView: View {
    let state: HomeViewState
    let expandedLevelIDs: Set<String>
    let onLevelTapped: (String) -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(state.levels) { level in
                    LevelCard(
                        viewState: level,
                        isExpanded: expandedLevelIDs.contains(level.id),
                        action: { onLevelTapped(level.id) },
                        onSessionTapped: onSessionTapped
                    )
                }
            }
            .padding()
        }
    }
}
