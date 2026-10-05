import SwiftUI

import DesignSystem

struct DeleteAccountConfirmSheet: View {
    @Binding var confirmText: String
    let isConfirmed: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("회원 탈퇴")
                .typography(DesignSystemTypography.Pretendard.extraBold22)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
                .padding(.top, 28)
                .padding(.horizontal, 26)
                .padding(.bottom, 14)

            Text("회원 탈퇴 시 학습한 데이터가 모두 지워집니다.")
                .typography(DesignSystemTypography.Pretendard.semiBold15)
                .foregroundStyle(DesignSystemColor.Status.negative)
                .padding(.horizontal, 26)
                .padding(.bottom, 20)

            Text("탈퇴하시려면 아래에 \"회원탈퇴\"를 입력하세요.")
                .typography(DesignSystemTypography.Pretendard.medium13)
                .foregroundStyle(DesignSystemColor.Foreground.strong.opacity(0.5))
                .padding(.horizontal, 26)
                .padding(.bottom, 10)

            TextField("회원탈퇴", text: $confirmText)
                .typography(DesignSystemTypography.Pretendard.medium16)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
                .tint(DesignSystemColor.Accent.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DesignSystemColor.Border.default, lineWidth: 1)
                )
                .padding(.horizontal, 26)
                .padding(.bottom, 28)

            DeleteAccountActionRow(
                isConfirmed: isConfirmed,
                onConfirm: onConfirm,
                onCancel: onCancel
            )
            .padding(.horizontal, 26)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemColor.Base.white)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: DesignSystemColor.Foreground.strong.opacity(0.1), radius: 16, x: 0, y: -4)
    }
}
