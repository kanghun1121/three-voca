import SwiftUI

import DesignSystem

/// 문법 분석 대상 예문을 요약해 보여주는 카드. `문법 분석 · <레벨>` 칩 아래 대상 단어가
/// 노란 배경으로 하이라이트된 문장을 렌더한다.
struct ChatBotContextCardView: View {
    let context: ChatBotContext
    // NLTagger 파이프라인은 view 생성/body 평가를 막지 않도록 task()에서 채운다
    @State private var highlightedSentence: Text?

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Image(systemName: "square.grid.2x2.fill")
                    .typography(DesignSystemTypography.Pretendard.regular10)
                Text("문법 분석 · \(context.levelLabel)")
                    .typography(DesignSystemTypography.Pretendard.extraBold12)
            }
            .foregroundStyle(DesignSystemColor.Accent.selectedBlue)

            (highlightedSentence ?? Text(context.sentence))
                .typography(DesignSystemTypography.Pretendard.semiBold15)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemColor.Base.white)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignSystemColor.Border.default, lineWidth: 1)
        }
        .task(id: "\(context.term)|\(context.sentence)") {
            highlightedSentence = Text(SentenceHighlighter.highlighted(
                sentence: context.sentence,
                keyword: context.term,
                font: DesignSystemTypography.Pretendard.semiBold15.font,
                highlightFont: DesignSystemTypography.Pretendard.bold15.font,
                highlightTextColor: DesignSystemColor.Accent.selectedBlue,
                highlightBackgroundColor: DesignSystemColor.Accent.selectedBlue100
            ))
        }
    }
}

#Preview("ChatBotContextCard") {
    ChatBotContextCardView(context: .init(
        wordID: "word_766",
        term: "address",
        sentence: "Please write your home address on this form.",
        levelLabel: "초급"
    ))
    .padding(16)
}
