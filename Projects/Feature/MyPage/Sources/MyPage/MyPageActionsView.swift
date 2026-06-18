import SwiftUI

import DesignSystem

struct MyPageActionsView: View {
    let onLogoutTapped: () -> Void
    let onDeleteAccountTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onLogoutTapped) {
                Text("로그아웃")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(DesignSystemAsset.border.swiftUIColor)
                .frame(width: 1, height: 12)
                .padding(.horizontal, 18)

            Button(action: onDeleteAccountTapped) {
                Text("회원 탈퇴")
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.negative.swiftUIColor)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.bottom, 44)
    }
}
