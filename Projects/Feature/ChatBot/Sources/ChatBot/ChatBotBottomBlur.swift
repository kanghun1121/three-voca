import SwiftUI

/// 입력바 아래(하단 여백 + 안전영역/키보드 뒤)에만 놓이는 블러 띠.
/// 입력바 쪽은 투명하게 시작해 아래로 갈수록 진해지므로 경계선이 보이지 않는다.
struct ChatBotBottomBlur: View {
    var body: some View {
        Color.clear
            .frame(height: 14)
            .background {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    // 머티리얼이 하단 안전영역(키보드 뒤 포함)까지 이어지게 한다.
                    .ignoresSafeArea(edges: .bottom)
            }
            // 앱 컬러가 라이트 전용이라 다크 모드에서 머티리얼만 어두워지지 않게 고정한다.
            .environment(\.colorScheme, .light)
    }
}
