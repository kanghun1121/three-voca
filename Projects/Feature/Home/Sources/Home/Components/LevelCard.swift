import SwiftUI

import DesignSystem

struct LevelCard: View {
    let presentationModel: LevelCardPresentationModel
    let isExpanded: Bool
    let action: () -> Void
    let onSessionTapped: (Int) -> Void

    private let maxVisibleSessions = 6

    private var visibleSessions: [SessionRowPresentationModel] {
        Array(presentationModel.sessions.prefix(maxVisibleSessions))
    }

    private var overflowCount: Int {
        max(0, presentationModel.sessions.count - maxVisibleSessions)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                headerRow
            }
            .buttonStyle(.plain)
            progressBar
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)
                sessionListRows
            }
        }
        .background(DesignSystemAsset.white.swiftUIColor)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    presentationModel.status == .active
                        ? DesignSystemAsset.primary.swiftUIColor.opacity(0.18)
                        : DesignSystemAsset.borderSubtle.swiftUIColor,
                    lineWidth: 1
                )
        }
        .animation(.easeOut(duration: 0.2), value: isExpanded)
    }

    private var headerRow: some View {
        HStack(spacing: 13) {
            Text(presentationModel.name)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 15.5))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            if let badge = presentationModel.status.badgeInfo {
                statusBadge(badge)
            }
            Spacer()
            Text("\(presentationModel.completedSessions)/\(presentationModel.totalSessions)")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 17))
                .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }

    private func statusBadge(_ info: (text: String, fg: Color, bg: Color)) -> some View {
        Text(info.text)
            .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 10.5))
            .foregroundStyle(info.fg)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(info.bg)
            .clipShape(.rect(cornerRadius: 100))
    }

    private var progressBar: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystemAsset.progressTrack.swiftUIColor)
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    presentationModel.status == .notStarted
                        ? DesignSystemAsset.fgMuted.swiftUIColor.opacity(0.3)
                        : DesignSystemAsset.primary.swiftUIColor
                )
                .scaleEffect(
                    x: max(0, min(1, presentationModel.progressRatio)),
                    anchor: .leading
                )
        }
        .frame(height: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var sessionListRows: some View {
        VStack(spacing: 0) {
            ForEach(visibleSessions) { session in
                Button {
                    onSessionTapped(session.id)
                } label: {
                    SessionRow(presentationModel: session)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 9)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
            }
            if overflowCount > 0 {
                Text("+ \(overflowCount)개 세션")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
            }
        }
    }
}

private extension LevelStatus {
    var badgeInfo: (text: String, fg: Color, bg: Color)? {
        switch self {
        case .active:
            return (
                "학습 중",
                DesignSystemAsset.primary.swiftUIColor,
                DesignSystemAsset.primary100.swiftUIColor
            )
        case .completed:
            return (
                "완료",
                DesignSystemAsset.positive.swiftUIColor,
                DesignSystemAsset.positive100.swiftUIColor
            )
        case .notStarted:
            return nil
        }
    }
}
