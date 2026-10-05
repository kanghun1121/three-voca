import SwiftUI

import DesignSystem

struct MyPageMenuView: View {
    let onPrivacyTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MenuRow(title: "문의사항")
            Rectangle()
                .fill(DesignSystemColor.Border.default)
                .frame(height: 1)
            MenuRow(title: "개인정보 처리방침", action: onPrivacyTapped)
        }
        .padding(.horizontal, 26)
    }
}

private struct MenuRow: View {
    let title: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Text(title)
                    .typography(DesignSystemTypography.Pretendard.medium16)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)

                Spacer()

                ChevronIcon()
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

private struct ChevronIcon: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .resizable()
            .scaledToFit()
            .frame(width: 9, height: 12)
            .foregroundStyle(DesignSystemColor.Foreground.strong)
            .typography(DesignSystemTypography.Content.bodyMedium)
    }
}
