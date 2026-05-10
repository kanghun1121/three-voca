import SwiftUI

struct LevelCard: View {
    let viewState: LevelCardViewState
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HeaderRow(viewState: viewState, isExpanded: isExpanded)
            ProgressBar(ratio: viewState.progressRatio)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                SessionList(sessions: viewState.sessions)
            }
        }
        .background(.white)
        .clipShape(.rect(cornerRadius: 12))
        .shadow(
            color: .black.opacity(0.06),
            radius: 4,
            x: 0,
            y: 2
        )
        .animation(.snappy, value: isExpanded)
        .onTapGesture(perform: action)
    }

    struct HeaderRow: View {
        let viewState: LevelCardViewState
        let isExpanded: Bool

        var body: some View {
            HStack(spacing: 10) {
                LevelBadge(text: viewState.levelBadgeText, color: viewState.levelBadgeColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewState.name)
                        .font(.subheadline)
                        .bold()
                    Text(viewState.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

    struct ProgressBar: View {
        let ratio: Double

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.20, green: 0.78, blue: 0.35))
                        .frame(width: geo.size.width * max(0, min(1, ratio)))
                }
            }
            .frame(height: 4)
        }
    }

    struct SessionList: View {
        let sessions: [SessionRowViewState]

        var body: some View {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    SessionRow(viewState: session)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    if session.id != sessions.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

#Preview("접힌 상태") {
    LevelCard(
        viewState: LevelCardViewState(
            id: "level_1",
            levelBadgeText: "L1",
            levelBadgeColor: .level1,
            name: "초등 기초",
            subtitle: "A1·A2 · 4/13",
            progressRatio: 4.0 / 13.0,
            sessions: []
        ),
        isExpanded: false,
        action: {}
    )
    .padding()
}

#Preview("펼친 상태") {
    LevelCard(
        viewState: LevelCardViewState(
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
        isExpanded: true,
        action: {}
    )
    .padding()
}
