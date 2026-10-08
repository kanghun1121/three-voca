import SwiftUI

import DesignSystem

struct DeleteAccountActionRow: View {
    let isConfirmed: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCancel) {
                Text("취소")
                    .typography(DesignSystemTypography.Pretendard.semiBold16)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DesignSystemColor.Border.default)
                    .clipShape(.rect(cornerRadius: 10))
            }

            Button(action: onConfirm) {
                Text("탈퇴")
                    .typography(DesignSystemTypography.Pretendard.semiBold16)
                    .foregroundStyle(DesignSystemColor.Base.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        DesignSystemColor.Status.negative
                            .opacity(isConfirmed ? 1 : 0.3)
                    )
                    .clipShape(.rect(cornerRadius: 10))
            }
            .disabled(!isConfirmed)
        }
    }
}
