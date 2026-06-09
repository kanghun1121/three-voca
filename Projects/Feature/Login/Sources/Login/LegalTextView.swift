import SwiftUI

import DesignSystem

struct LegalTextView: View {
    @ScaledMetric private var legalTextSize: CGFloat = 11

    let onTermsTapped: () -> Void
    let onPrivacyTapped: () -> Void

    var body: some View {
        Text(legalText)
            .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: legalTextSize))
            .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            .lineSpacing(6)
            .multilineTextAlignment(.center)
            .tint(DesignSystemAsset.fgMuted.swiftUIColor)
            .environment(\.openURL, OpenURLAction { url in
                switch url.absoluteString {
                case "fivevoca://terms":
                    onTermsTapped()
                    return .handled
                case "fivevoca://privacy":
                    onPrivacyTapped()
                    return .handled
                default:
                    return .systemAction
                }
            })
    }

    private var legalText: AttributedString {
        var terms = AttributedString("이용약관")
        terms.link = URL(string: "fivevoca://terms")
        terms.underlineStyle = .single

        var privacy = AttributedString("개인정보 처리방침")
        privacy.link = URL(string: "fivevoca://privacy")
        privacy.underlineStyle = .single

        return AttributedString("계속 진행하면 ") + terms + AttributedString("과 ") + privacy + AttributedString("에 동의하게 됩니다.")
    }
}
