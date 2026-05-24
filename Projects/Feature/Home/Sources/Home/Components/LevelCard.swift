import SwiftUI

struct LevelCard: View {
    let presentationModel: LevelCardPresentationModel
    let isExpanded: Bool
    let action: () -> Void
    let onSessionTapped: (Int) -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HeaderRow(presentationModel: presentationModel, isExpanded: isExpanded)
                ProgressBar(ratio: presentationModel.progressRatio)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                if isExpanded {
                    Divider()
                        .padding(.horizontal, 16)
                    SessionList(sessions: presentationModel.sessions, onSessionTapped: onSessionTapped)
                }
            }
            .background(Color(.systemBackground))
            .clipShape(.rect(cornerRadius: 12))
            .shadow(
                color: .black.opacity(0.06),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isExpanded)
    }

    struct HeaderRow: View {
        let presentationModel: LevelCardPresentationModel
        let isExpanded: Bool

        private var badgeText: String { "L\(presentationModel.level)" }
        private var subtitle: String {
            let diff = presentationModel.difficulty.replacingOccurrences(of: "-", with: "·")
            return "\(diff) · \(presentationModel.completedSessions)/\(presentationModel.totalSessions)"
        }

        var body: some View {
            HStack(spacing: 10) {
                LevelBadge(text: badgeText, color: presentationModel.levelBadgeColor)
                LevelInfo(name: presentationModel.name, subtitle: subtitle)
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
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(
                        red: 0.93,
                        green: 0.93,
                        blue: 0.93
                    ))
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(
                            red: 0.20,
                            green: 0.78,
                            blue: 0.35
                        ))
                        .frame(width: geo.size.width * max(0, min(1, ratio)))
                }
            }
            .frame(height: 4)
        }
    }

    struct SessionList: View {
        let sessions: [SessionRowPresentationModel]
        let onSessionTapped: (Int) -> Void

        var body: some View {
            LazyVStack(spacing: 0) {
                ForEach(sessions) { session in
                    Button {
                        onSessionTapped(session.id)
                    } label: {
                        SessionRow(presentationModel: session)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    if session.id != sessions.last?.id {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}
