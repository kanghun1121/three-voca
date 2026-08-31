import SwiftUI

import DesignSystem

/// AI 응답 말풍선 — 좌측 정렬. 자리표시 상태(`isGenerating`)일 땐 스피너 + 대기 문구만
/// 보여주고, 텍스트가 도착하면 그림자가 있는 흰 말풍선으로 전환한다.
struct ChatBotAssistantBubbleView: View {
    let message: ChatBotMessage
    let isActivelyStreaming: Bool

    var body: some View {
        if message.isGenerating {
            HStack(spacing: 8) {
                ProgressView()
                    .tint(DesignSystemAsset.study300.swiftUIColor)
                Text("AI가 답변을 생성하고 있어요..")
                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
            .padding(.vertical, 11)
        } else {
            MarkdownView(markdown: message.text, fadesTail: isActivelyStreaming)
                .padding(.vertical, 11)
                .background(DesignSystemAsset.background.swiftUIColor)
                .clipShape(.rect(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 16
                ))
                .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
        }
    }
}

#Preview("응답 대기") {
    ChatBotAssistantBubbleView(
        message: ChatBotMessage(
            role: .assistant,
            text: "",
            isGenerating: true
        ),
        isActivelyStreaming: false
    )
    .padding(16)
}

#Preview("응답 완료") {
    ChatBotAssistantBubbleView(
        message: ChatBotMessage(
            role: .assistant,
            text: "이 문장에서 address는 write의 목적어로 쓰인 명사예요."
        ),
        isActivelyStreaming: false
    )
    .padding(16)
}
