import SwiftUI

import DesignSystem

struct HeatmapDayGutter: View {
    @ScaledMetric private var cellSize: CGFloat = 15
    @ScaledMetric private var cellGap: CGFloat = 3
    @ScaledMetric private var dayGutterWidth: CGFloat = 12

    private let labels = ["", "월", "", "수", "", "금", ""]

    var body: some View {
        VStack(alignment: .leading, spacing: cellGap) {
            ForEach(0..<7, id: \.self) { row in
                Text(labels[row])
                    .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 8.5))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
                    .frame(width: dayGutterWidth, height: cellSize, alignment: .leading)
            }
        }
    }
}
