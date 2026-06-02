import DesignSystem
import SwiftUI

struct WordDetailExamplesView: View {
    let term: String
    let examples: [WordDetailPresentationModel.ExampleRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("예문")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            ExampleList(term: term, examples: examples)
        }
    }
}

private struct ExampleList: View {
    let term: String
    let examples: [WordDetailPresentationModel.ExampleRow]

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(examples) { example in
                WordDetailExampleRow(term: term, example: example)
            }
        }
    }
}
