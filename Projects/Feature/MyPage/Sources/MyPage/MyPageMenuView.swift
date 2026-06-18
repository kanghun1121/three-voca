import SwiftUI

import DesignSystem

struct MyPageMenuView: View {
    let onInquiryTapped: () -> Void
    let onTermsTapped: () -> Void
    let onPrivacyTapped: () -> Void

    private let items: [(String, () -> Void)]

    init(
        onInquiryTapped: @escaping () -> Void,
        onTermsTapped: @escaping () -> Void,
        onPrivacyTapped: @escaping () -> Void
    ) {
        self.onInquiryTapped = onInquiryTapped
        self.onTermsTapped = onTermsTapped
        self.onPrivacyTapped = onPrivacyTapped
        items = [
            ("문의사항", onInquiryTapped),
            ("이용약관", onTermsTapped),
            ("개인정보 처리방침", onPrivacyTapped),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button(action: item.1) {
                    HStack {
                        Text(item.0)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                            .kerning(16 * -0.01)

                        Spacer()

                        ChevronIcon()
                    }
                    .padding(.vertical, 18)
                }
                .buttonStyle(.plain)

                if index < items.count - 1 {
                    Rectangle()
                        .fill(DesignSystemAsset.border.swiftUIColor)
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 26)
    }
}

private struct ChevronIcon: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .resizable()
            .scaledToFit()
            .frame(width: 9, height: 12)
            .foregroundStyle(DesignSystemAsset.primary.swiftUIColor.opacity(0.55))
            .fontWeight(.medium)
    }
}
