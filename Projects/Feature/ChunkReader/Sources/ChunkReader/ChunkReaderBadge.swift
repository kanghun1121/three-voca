import SwiftUI

import DesignSystem

struct ChunkReaderBadge: View {
    let icon: String
    let label: String

    var body: some View {
        Label {
            Text(label)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 11.5))
                .tracking(-0.01 * 12.5)
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 12))
        }
        .foregroundStyle(DesignSystemAsset.selectedBlue.swiftUIColor)
        .padding(.init(top: 5, leading: 9, bottom: 5, trailing: 9))
        .overlay {
            Capsule()
                .stroke(DesignSystemAsset.selectedBlue.swiftUIColor.opacity(0.4), lineWidth: 1)
        }
    }
}
