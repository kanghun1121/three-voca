import SwiftUI

import DesignSystem

struct WordDetailExampleRow: View {
    let term: String
    let example: WordDetailPresentationModel.ExampleRow
    let onChunkReaderTapped: (WordDetailPresentationModel.ExampleRow) -> Void
    // NLTagger 파이프라인은 view 생성/body 평가를 막지 않도록 task()에서 채운다
    @State private var highlightedEnText: Text? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            (highlightedEnText ?? Text(example.en))
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)

            Text(example.ko)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

            if let chunks = example.chunks, !chunks.isEmpty {
                Button {
                    onChunkReaderTapped(example)
                } label: {
                    Label {
                        Text("끊어읽기")
                            .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                    } icon: {
                        Image(systemName: "text.word.spacing")
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(DesignSystemAsset.study300.swiftUIColor)
                }
                .padding(.vertical, 8)
                .contentShape(.rect)
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemAsset.study100.swiftUIColor.opacity(0.5))
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(DesignSystemAsset.study100.swiftUIColor, lineWidth: 1)
        }
        .task(id: "\(term)|\(example.en)") {
            highlightedEnText = Text(SentenceHighlighter.highlighted(
                sentence: example.en,
                keyword: term,
                font: DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16),
                highlightFont: DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16)
            ))
        }
    }
}
