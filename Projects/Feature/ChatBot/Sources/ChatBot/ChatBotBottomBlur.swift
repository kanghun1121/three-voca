import SwiftUI

import DesignSystem

/// 입력바 아래(하단 여백 + 안전영역/키보드 뒤)에만 놓이는 블러 띠.
/// 입력바 쪽은 투명하게 시작해 아래로 갈수록 진해지므로 경계선이 보이지 않는다.
struct ChatBotBottomBlur: View {
    var body: some View {
        DesignSystemColor.clear
            .frame(height: 14)
            .background {
                Rectangle()
                    .fill(DesignSystemStyle.bottomBlurMaterial)
                    .mask(
                        LinearGradient(
                            colors: [DesignSystemColor.clear, DesignSystemColor.Base.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    // 머티리얼이 하단 안전영역(키보드 뒤 포함)까지 이어지게 한다.
                    .ignoresSafeArea(edges: .bottom)
            }
    }
}
