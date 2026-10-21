import SwiftUI

import DesignSystem

struct MultipleChoiceCloseRow: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .typography(DesignSystemTypography.Pretendard.semiBold16)
                    .foregroundStyle(DesignSystemColor.Base.white)
                    .frame(width: 40, height: 40)
            }
            .padding(.leading, 10)
            .accessibilityLabel("닫기")

            Spacer()

            Spacer().frame(width: 40)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
}
