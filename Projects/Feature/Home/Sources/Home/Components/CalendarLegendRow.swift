import SwiftUI

import DesignSystem

struct CalendarLegendRow: View {
    let studiedDaysCount: Int

    private static let swatchColors: [Color] = [
        CalendarDayIntensity.lv0.background,
        CalendarDayIntensity.lv1.background,
        CalendarDayIntensity.lv2.background,
        CalendarDayIntensity.lv3.background,
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Rectangle()
                .fill(DesignSystemAsset.borderSubtle.swiftUIColor)
                .frame(height: 1)
            HStack(spacing: 0) {
                countLabel
                Spacer()
                scale
            }
        }
        .padding(.top, 16)
    }

    private var countLabel: some View {
        HStack(spacing: 0) {
            Text("이번 달 ")
            Text("\(studiedDaysCount)일")
                .foregroundStyle(DesignSystemAsset.positive.swiftUIColor)
            Text(" 학습")
        }
        .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
        .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
    }

    private var scale: some View {
        HStack(spacing: 4) {
            Text("적음")
            ForEach(Array(Self.swatchColors.enumerated()), id: \.offset) { _, color in
                RoundedRectangle(cornerRadius: 3.5)
                    .fill(color)
                    .frame(width: 11, height: 11)
            }
            Text("많음")
        }
        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 10))
        .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
    }
}
