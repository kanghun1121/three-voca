import SwiftUI

struct ChatBotInputBarSection: View {
    @Bindable var viewModel: ChatBotViewModel
    var isInputFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 0) {
            ChatBotInputBar(
                placeholder: "\(viewModel.context.term)에 대해 물어보세요",
                text: $viewModel.input,
                state: viewModel.isStreaming ? .stop : .send(isEnabled: viewModel.canSend),
                isFocused: isInputFocused,
                onSend: { viewModel.didTapSend() },
                onStop: { viewModel.didTapStop() }
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)

            ChatBotBottomBlur()
        }
    }
}
