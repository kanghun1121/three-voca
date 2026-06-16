import SwiftUI

import DesignSystem

struct MultipleChoiceCloseRow: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .frame(width: 40, height: 40)
            }
            .padding(.leading, 10)
            .accessibilityLabel("닫기")

            Spacer()

            Text("뜻")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .tracking(0.12 * 12)
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))

            Spacer()

            Spacer().frame(width: 40)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
    }
}
