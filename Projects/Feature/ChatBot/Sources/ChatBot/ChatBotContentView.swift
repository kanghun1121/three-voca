import SwiftUI

import DesignSystem

/// 문법 분석 화면 본문 — AnalysisCard는 고정 헤더가 아니라 채팅 컨텐츠의 첫 항목이라
/// 메시지와 함께 스크롤되어 사라진다. 입력바만 그 위에 플로팅 레이어로 얹힌다
/// (`chatArea`의 `.safeAreaInset` 참고) — 입력바가 다중 행으로 늘어나도 마지막 메시지가
/// 가려지지 않는다.
///
/// 전송 시 ChatGPT처럼 방금 보낸 질문을 화면 맨 위로 스크롤한다 — 그 아래 AI 응답 자리에
/// 뷰포트 높이만큼의 최소 높이를 줘서, 응답이 아직 짧거나 비어 있어도 빈 공간이 남는다.
struct ChatBotContentView: View {
    @Bindable var viewModel: ChatBotViewModel
    // GeometryReader는 안전 영역(safe area)을 무시하고 자신에게 주어진 프레임을 그대로
    // 차지해버려 컨텐츠가 네비게이션 바 아래로 파고드는 문제가 있었다. 레이아웃에 영향을
    // 주지 않고 크기만 관찰하는 onGeometryChange로 측정해 안전 영역을 다시 존중하게 한다.
    @State private var chatAreaHeight: CGFloat = 0

    var body: some View {
        chatArea
            .background(DesignSystemAsset.background.swiftUIColor)
    }

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    AnalysisCardView(context: viewModel.context)

                    ForEach(viewModel.messages) { message in
                        let isLastMessage = message.id == viewModel.messages.last?.id

                        ChatBotMessageRow(
                            message: message,
                            isActivelyStreaming: viewModel.isStreaming && isLastMessage
                        )
                        .id(message.id)
                        .frame(
                            minHeight: isLastMessage && message.role == .assistant
                                ? chatAreaHeight
                                : nil,
                            alignment: .top
                        )
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(DesignSystemAsset.negative.swiftUIColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }
            .onGeometryChange(for: CGFloat.self) { geometryProxy in
                geometryProxy.size.height
            } action: { newHeight in
                chatAreaHeight = newHeight
            }
            .onChange(of: viewModel.messages.count) {
                guard let lastUserMessageID = viewModel.messages.last(where: { $0.role == .user })?.id else { return }
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(lastUserMessageID, anchor: .top)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) { inputBar }
    }

    private var inputBar: some View {
        ChatBotInputBar(
            placeholder: "\(viewModel.context.term)에 대해 물어보세요",
            text: $viewModel.input,
            state: viewModel.isStreaming ? .cancel : .send(isEnabled: viewModel.canSend),
            onSend: { viewModel.didTapSend() },
            onCancel: { viewModel.didTapCancel() }
        )
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }
}
