import SwiftUI

import DesignSystem

struct MyPageActionsView: View {
    let onLogoutTapped: () -> Void
    let onDeleteAccountTapped: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onLogoutTapped) {
                Text("로그아웃")
                    .typography(DesignSystemTypography.Pretendard.semiBold14)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(DesignSystemColor.Border.default)
                .frame(width: 1, height: 12)
                .padding(.horizontal, 18)

            Button(action: onDeleteAccountTapped) {
                Text("회원 탈퇴")
                    .typography(DesignSystemTypography.Pretendard.semiBold14)
                    .foregroundStyle(DesignSystemColor.Status.negativeText)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.bottom, 22)
    }
}
