import SwiftUI

import DesignSystem

struct LegalTextView: View {
    let onTermsTapped: () -> Void
    let onPrivacyTapped: () -> Void

    var body: some View {
        (Text("계속 진행하면 ")
        + Text("이용약관")
            .underline()
        + Text("과 ")
        + Text("개인정보 처리방침")
            .underline()
        + Text("에 동의하게 됩니다."))
        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 11))
        .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
        .lineSpacing(6)
        .multilineTextAlignment(.center)
    }
}
