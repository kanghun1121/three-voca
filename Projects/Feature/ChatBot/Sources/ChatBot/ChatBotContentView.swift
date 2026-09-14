import SwiftUI

import DesignSystem

struct ChatBotContentView: View {
    @Bindable var viewModel: ChatBotViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ChatArea(viewModel: viewModel, isInputFocused: $isInputFocused)
            .background(DesignSystemAsset.background.swiftUIColor)
    }
}
