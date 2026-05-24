import SwiftUI

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
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
