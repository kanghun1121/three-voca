import SwiftUI

struct HomeContentView: View {
    let state: HomeViewState
    let expandedLevelIDs: Set<String>
    let onToggleLevel: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HomeHeaderView(streakDays: state.streakDays)
                    .padding(.horizontal)
                    .padding(.top, 8)
                LevelList(
                    levels: state.levels,
                    expandedLevelIDs: expandedLevelIDs,
                    onToggleLevel: onToggleLevel
                )
            }
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    HomeContentView(
        state: HomeViewState(streakDays: 7, levels: [
            LevelCardViewState(
                id: "level_1",
                levelBadgeText: "L1",
                levelBadgeColor: .level1,
                name: "초등 기초",
                subtitle: "A1·A2 · 4/13 완료",
                progressRatio: 4.0 / 13.0,
                sessions: [
                    SessionRowViewState(
                        id: 1,
                        title: "Session 1",
                        subtitle: "완료 · 9일 전 · 정답률 92%",
                        icon: .completedHigh
                    ),
                    SessionRowViewState(
                        id: 2,
                        title: "Session 2",
                        subtitle: "완료 · 3일 전 · 정답률 87%",
                        icon: .completedHigh
                    ),
                    SessionRowViewState(
                        id: 3,
                        title: "Session 3",
                        subtitle: "완료 · 6일 전 · 정답률 58%",
                        icon: .completedLow
                    ),
                    SessionRowViewState(
                        id: 5,
                        title: "Session 5",
                        subtitle: "시작 전",
                        icon: .notStarted
                    ),
                    SessionRowViewState(
                        id: 6,
                        title: "Session 6",
                        subtitle: "시작 전",
                        icon: .notStarted
                    ),
                ]
            ),
            LevelCardViewState(
                id: "level_2",
                levelBadgeText: "L2",
                levelBadgeColor: .level2,
                name: "초등 심화",
                subtitle: "A2 · 0/39 완료",
                progressRatio: 0,
                sessions: []
            ),
            LevelCardViewState(
                id: "level_3",
                levelBadgeText: "L3",
                levelBadgeColor: .level3,
                name: "중등 ~ 수능",
                subtitle: "B1·B2 · 0/99 완료",
                progressRatio: 0,
                sessions: []
            ),
        ]),
        expandedLevelIDs: ["level_1"]
    ) { _ in }
}

#Preview("다크 모드") {
    HomeContentView(
        state: HomeViewState(streakDays: 7, levels: [
            LevelCardViewState(
                id: "level_1",
                levelBadgeText: "L1",
                levelBadgeColor: .level1,
                name: "초등 기초",
                subtitle: "A1·A2 · 4/42 완료",
                progressRatio: 4.0 / 42.0,
                sessions: [
                    SessionRowViewState(
                        id: 1,
                        title: "Session 1",
                        subtitle: "완료 · 9일 전 · 정답률 92%",
                        icon: .completedHigh
                    ),
                    SessionRowViewState(
                        id: 5,
                        title: "Session 5",
                        subtitle: "시작 전",
                        icon: .notStarted
                    ),
                ]
            ),
        ]),
        expandedLevelIDs: ["level_1"]
    ) { _ in }
    .preferredColorScheme(.dark)
}
