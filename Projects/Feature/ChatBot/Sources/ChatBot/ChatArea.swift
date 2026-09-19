import SwiftUI

struct ChatArea: View {
    @Bindable var viewModel: ChatBotViewModel
    var isInputFocused: FocusState<Bool>.Binding

    @State private var chatAreaHeight: CGFloat = 0
    @State private var isScrolledToBottom = true

    private static let bottomAnchorID = "chat-bottom-anchor"
    private static let bottomThreshold: CGFloat = 300

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ChatBotContextCardView(context: viewModel.context)

                    ForEach(viewModel.messages) { message in
                        let isLastMessage = message.id == viewModel.messages.last?.id
                        let isActivelyStreaming = viewModel.isStreaming && isLastMessage
                        let reservesFullHeight = isLastMessage && message.role == .assistant && !message.isFromHistory

                        ChatBotMessageRow(message: message, isActivelyStreaming: isActivelyStreaming)
                            .id(message.id)
                            .frame(minHeight: reservesFullHeight ? chatAreaHeight : nil, alignment: .top)
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(Self.bottomAnchorID)
                }
                .padding(16)
                // 대화가 짧아 콘텐츠가 뷰포트보다 낮아도, 스크롤 영역 전체(빈 공간 포함)에서
                // 탭이 되도록 최소 뷰포트 높이만큼은 확보한다.
                .frame(minHeight: chatAreaHeight, alignment: .top)
                // 빈 영역도 탭 대상에 포함
                .contentShape(Rectangle())
                .onTapGesture { isInputFocused.wrappedValue = false }
            }
            // 카카오톡/ChatGPT처럼, 메시지 목록을 아래로 드래그한 만큼 키보드도 따라 내려가고
            // dismiss 임계값을 못 넘기면 다시 스프링백한다. 하단 입력바의 TextField에까지
            // 전달되지 않도록 ScrollView 자신에게만 붙인다.
            .scrollDismissesKeyboard(.interactively)
            .onGeometryChange(for: CGFloat.self) { geometryProxy in
                geometryProxy.size.height
            } action: { newHeight in
                chatAreaHeight = newHeight
            }
            .onScrollGeometryChange(for: ScrollViewport.self) { geometry in
                ScrollViewport(geometry: geometry, threshold: Self.bottomThreshold)
            } action: { old, new in
                isScrolledToBottom = new.isNearBottom
                // 키보드로 스크롤 뷰가 줄어들 때, 직전까지 최하단 근처였다면 최하단을 유지해
                // 하단 콘텐츠가 키보드에 가려지지 않고 함께 올라오게 한다.
                if new.shouldKeepBottom(after: old) {
                    proxy.scrollTo(Self.bottomAnchorID, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.count) {
                scrollToLastUserMessageIfStreaming(proxy: proxy)
                scrollToBottomIfHistoryUpdated(proxy: proxy)
            }
            .task {
                await viewModel.load()
            }
            .overlay(alignment: .bottom) {
                if !isScrolledToBottom {
                    ScrollToBottomButton { scrollToBottom(proxy: proxy) }
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            ChatBotInputBarSection(viewModel: viewModel, isInputFocused: isInputFocused)
        }
    }

    // MARK: - 스크롤 보정

    private func scrollToLastUserMessageIfStreaming(proxy: ScrollViewProxy) {
        guard viewModel.isStreaming else { return }
        guard let lastUserMessageID = viewModel.messages.last(where: { $0.role == .user })?.id else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(lastUserMessageID, anchor: .top)
        }
        // 이 시점엔 방금 추가된 assistant 자리표시 행의 `.frame(minHeight: chatAreaHeight)`
        // 예약 공간이 아직 레이아웃에 반영되기 전이라, anchor: .top 스크롤이 아직 작은
        // 콘텐츠 크기 기준으로 클램프돼 최상단까지 닿지 못할 수 있다 — 다음 런루프에서
        // 한 번 더 보정한다.
        Task {
            proxy.scrollTo(lastUserMessageID, anchor: .top)
        }
    }

    private func scrollToBottomIfHistoryUpdated(proxy: ScrollViewProxy) {
        // 히스토리 로드(`load()`)는 로컬 캐시 → 원격 순으로 두 번 나눠 messages를 갱신한다.
        // `load()`가 끝나길 기다렸다가 한 번만 스크롤하면, 캐시가 반영된 첫 번째 갱신
        // 시점엔 아무 스크롤도 일어나지 않는다 — 갱신될 때마다 즉시 최하단으로 보정한다.
        guard !viewModel.isStreaming else { return }
        proxy.scrollTo(Self.bottomAnchorID, anchor: .bottom)
        // LazyVStack이 방금 삽입된 셀을 아직 레이아웃하기 전이라 위 호출만으론 맨
        // 아래에 정확히 닿지 않을 수 있다 — 다음 런루프에서 한 번 더 보정한다.
        Task {
            proxy.scrollTo(Self.bottomAnchorID, anchor: .bottom)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(Self.bottomAnchorID, anchor: .bottom)
        }
    }
}
