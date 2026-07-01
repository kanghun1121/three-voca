import SwiftUI

import DesignSystem

struct ChunkReaderWordListHeader: View {
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 8) {
            Text("단어 뜻")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            Text("문장 등장 순서")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
        }
    }
}
