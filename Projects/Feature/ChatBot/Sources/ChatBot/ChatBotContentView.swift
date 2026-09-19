import SwiftUI

import DesignSystem

struct ChatBotContentView: View {
    @Bindable var viewModel: ChatBotViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ChatArea(viewModel: viewModel, isInputFocused: $isInputFocused)
            // 키보드 뒤 영역까지 채운다 — 안 그러면 다크 모드에서 시스템 배경(검정)이 비친다.
            .background {
                DesignSystemAsset.background.swiftUIColor.ignoresSafeArea()
            }
    }
}
