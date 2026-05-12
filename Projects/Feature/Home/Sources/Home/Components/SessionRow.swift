import SwiftUI

struct SessionRow: View {
    let viewState: SessionRowViewState

    var body: some View {
        HStack(spacing: 12) {
            SessionStatusIcon(kind: viewState.icon)
            SessionInfo(title: viewState.title, subtitle: viewState.subtitle)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SessionRow(viewState: SessionRowViewState(
            id: 1,
            title: "Session 1",
            subtitle: "완료 · 9일 전 · 정답률 92%",
            icon: .completedHigh
        ))
        SessionRow(viewState: SessionRowViewState(
            id: 2,
            title: "Session 3",
            subtitle: "완료 · 6일 전 · 정답률 58%",
            icon: .completedLow
        ))
        SessionRow(viewState: SessionRowViewState(
            id: 3,
            title: "Session 5",
            subtitle: "시작 전",
            icon: .notStarted
        ))
        SessionRow(viewState: SessionRowViewState(
            id: 4,
            title: "Session 6",
            subtitle: "시작 전",
            icon: .notStarted
        ))
    }
    .padding()
}
