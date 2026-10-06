import SwiftUI

import DesignSystem

struct MyPageMenuView: View {
    let viewModel: MyPageViewModel
    let appearanceTitle: String

    var body: some View {
        VStack(spacing: 0) {
            MenuRow(title: "다크 모드", value: appearanceTitle, action: viewModel.appearanceTapped)
            Rectangle()
                .fill(DesignSystemColor.Border.default)
                .frame(height: 1)
            MenuRow(title: "문의사항")
            Rectangle()
                .fill(DesignSystemColor.Border.default)
                .frame(height: 1)
            MenuRow(title: "개인정보 처리방침", action: viewModel.privacyTapped)
            #if DEV_ENVIRONMENT
            if !viewModel.isAuthenticated {
                Rectangle()
                    .fill(DesignSystemAsset.border.swiftUIColor)
                    .frame(height: 1)
                MenuRow(
                    title: viewModel.isSigningInWithTestAccount ? "로그인 중…" : "테스트 계정 로그인",
                    action: viewModel.testAccountLoginTapped
                )
                .disabled(viewModel.isSigningInWithTestAccount)
            }
            #endif
        }
        .padding(.horizontal, 26)
    }
}

private struct MenuRow: View {
    let title: String
    var value: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: action ?? {}) {
            HStack {
                Text(title)
                    .typography(DesignSystemTypography.Pretendard.medium16)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)

                Spacer()

                if let value {
                    Text(value)
                        .typography(DesignSystemTypography.Pretendard.medium14)
                        .foregroundStyle(DesignSystemColor.Text.secondary)
                }

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
