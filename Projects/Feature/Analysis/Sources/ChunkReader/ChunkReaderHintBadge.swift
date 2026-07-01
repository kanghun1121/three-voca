import SwiftUI

import DesignSystem

struct ChunkReaderHintBadge: View {
    var body: some View {
        Label {
            Text("의미 단위로 해석해보자")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
        } icon: {
            Image(systemName: "bolt.fill")
                .font(.system(size: 12))
        }
        .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(DesignSystemAsset.study100.swiftUIColor.opacity(0.5))
        .clipShape(.capsule)
        .overlay {
            Capsule()
                .stroke(DesignSystemAsset.study300.swiftUIColor, lineWidth: 1)
        }
    }
}
