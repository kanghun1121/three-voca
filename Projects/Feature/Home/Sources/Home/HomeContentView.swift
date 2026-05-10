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

#Preview {
    HomeContentView(
        state: HomeViewState(levels: [
            LevelCardViewState(
                id: "level_1",
                levelBadgeText: "L1",
                levelBadgeColor: .level1,
                name: "초등 기초",
                subtitle: "A1·A2 · 4/13",
                progressRatio: 4.0 / 13.0,
                sessions: [
                    SessionRowViewState(
                        id: "s1",
                        title: "Session 1",
                        trailingText: "완료 · 92%",
                        icon: .completedHigh
                    ),
                    SessionRowViewState(
                        id: "s2",
                        title: "Session 2",
                        trailingText: "완료 · 87%",
                        icon: .completedHigh
                    ),
                    SessionRowViewState(
                        id: "s3",
                        title: "Session 3",
                        trailingText: "완료 · 58%",
                        icon: .completedLow
                    ),
                    SessionRowViewState(
                        id: "s5",
                        title: "Session 5",
                        trailingText: "시작 전",
                        icon: .notStarted
                    ),
                    SessionRowViewState(
                        id: "s6",
                        title: "Session 6",
                        trailingText: "시작 전",
                        icon: .notStarted
                    ),
                ]
            ),
            LevelCardViewState(
                id: "level_2",
                levelBadgeText: "L2",
                levelBadgeColor: .level2,
                name: "초등 심화",
                subtitle: "B1 · 0/17",
                progressRatio: 0,
                sessions: []
            ),
            LevelCardViewState(
                id: "level_3",
                levelBadgeText: "L3",
                levelBadgeColor: .level3,
                name: "중등 기본",
                subtitle: "B2 · 0/40",
                progressRatio: 0,
                sessions: []
            ),
        ]),
        expandedLevelIDs: ["level_1"],
        onToggleLevel: { _ in }
    )
}
