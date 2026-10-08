import SwiftUI

import DesignSystem

struct MyPageHeaderView: View {
    var body: some View {
        Text("마이페이지")
            .typography(DesignSystemTypography.Pretendard.extraBold26)
            .foregroundStyle(DesignSystemColor.Foreground.strong)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 20)
            .padding(.horizontal, 26)
            .padding(.bottom, 30)
    }
}
