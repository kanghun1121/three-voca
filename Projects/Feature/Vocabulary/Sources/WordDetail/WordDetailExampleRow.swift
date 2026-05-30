import DesignSystem
import SwiftUI

struct WordDetailExampleRow: View {
    let term: String
    let example: WordDetailPresentationModel.ExampleRow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            highlightedText(sentence: example.en, keyword: term)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)

            Text(example.ko)
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)

            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.system(size: 11))
                    Text("문법 분석")
                        .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                }
                .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemAsset.bgSubtle.swiftUIColor)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func highlightedText(sentence: String, keyword: String) -> Text {
        let lower = sentence.lowercased()
        let keyLower = keyword.lowercased()

        guard let range = lower.range(of: keyLower) else {
            return Text(sentence)
        }

        let before = String(sentence[sentence.startIndex..<range.lowerBound])
        let match = String(sentence[range])
        let after = String(sentence[range.upperBound...])

        // SwiftUI Text는 background를 Text 연결에서 지원하지 않으므로
        // bold + cautionary 색상으로 키워드를 강조 표시
        return Text(before)
            + Text(match)
                .bold()
                .foregroundStyle(DesignSystemAsset.cautionary.swiftUIColor)
            + Text(after)
    }
}
