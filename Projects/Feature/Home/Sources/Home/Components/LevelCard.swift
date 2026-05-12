import SwiftUI

struct LevelCard: View {
    let viewState: LevelCardViewState
    let isExpanded: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HeaderRow(viewState: viewState, isExpanded: isExpanded)
                ProgressFill(ratio: viewState.progressRatio)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                if isExpanded {
                    SessionList(sessions: viewState.sessions)
                }
            }
            .background(HomeColors.cardBackground)
            .clipShape(.rect(cornerRadius: 12))
            .shadow(
                color: colorScheme == .dark ? .clear : .black.opacity(0.06),
                radius: 4,
                x: 0,
                y: 2
            )
            .animation(reduceMotion ? nil : .snappy, value: isExpanded)
        }
        .buttonStyle(.plain)
    }
}

#Preview("접힌 상태") {
    LevelCard(
        viewState: LevelCardViewState(
            id: "level_1",
            levelBadgeText: "L1",
            levelBadgeColor: .level1,
            name: "초등 기초",
            subtitle: "A1·A2 · 4/13 완료",
            progressRatio: 4.0 / 13.0,
            sessions: []
        ),
        isExpanded: false
    ) {}
    .padding()
}

#Preview("펼친 상태") {
    LevelCard(
        viewState: LevelCardViewState(
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
        isExpanded: true
    ) {}
    .padding()
}

#Preview("다크 모드") {
    LevelCard(
        viewState: LevelCardViewState(
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
                    id: 5,
                    title: "Session 5",
                    subtitle: "시작 전",
                    icon: .notStarted
                ),
            ]
        ),
        isExpanded: true
    ) {}
    .padding()
    .preferredColorScheme(.dark)
}
