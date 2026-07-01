import SwiftUI

import DesignSystem

struct ChunkReaderHintBadge: View {
    var body: some View {
        Label {
            Text("의미 단위 해석")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
        } icon: {
            Image(systemName: "bolt.fill")
                .font(.system(size: 10))
        }
        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DesignSystemAsset.study100.swiftUIColor.opacity(0.5))
        .clipShape(.capsule)
        .overlay {
            Capsule()
                .stroke(DesignSystemAsset.study300.swiftUIColor, lineWidth: 1)
        }
    }
}
