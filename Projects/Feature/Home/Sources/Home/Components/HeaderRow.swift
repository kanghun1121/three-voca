import SwiftUI

struct HeaderRow: View {
    let viewState: LevelCardViewState
    let isExpanded: Bool

    var body: some View {
        HStack(spacing: 10) {
            LevelBadge(text: viewState.levelBadgeText, color: viewState.levelBadgeColor)
            LevelInfo(name: viewState.name, subtitle: viewState.subtitle)
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
