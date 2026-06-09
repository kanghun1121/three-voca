import SwiftUI

import DesignSystem

struct FloatingWordCardView: View {
    let word: String
    let meaning: String
    let tagKind: TagKind

    enum TagKind {
        case know
        case time
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text(word)
                    .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 18))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    .kerning(18 * -0.012)

                Spacer()

                tagView
            }
            .padding(.bottom, 4)

            Text(meaning)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 220)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.12), radius: 16, x: 0, y: 12)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.04), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var tagView: some View {
        switch tagKind {
        case .know:
            Text("✓ 안다")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 10))
                .foregroundStyle(DesignSystemAsset.positive.swiftUIColor)
                .kerning(10 * 0.04)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(DesignSystemAsset.positive100.swiftUIColor)
                .clipShape(Capsule())
        case .time:
            Text("3s")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 10))
                .foregroundStyle(DesignSystemAsset.cautionary.swiftUIColor)
                .kerning(10 * 0.04)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(DesignSystemAsset.cautionary100.swiftUIColor)
                .clipShape(Capsule())
        }
    }
}
