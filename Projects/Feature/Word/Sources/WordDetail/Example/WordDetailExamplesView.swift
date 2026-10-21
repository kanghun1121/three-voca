import SwiftUI

import DesignSystem
import DomainInterface

struct WordDetailExamplesView: View {
    let term: String
    let examples: [WordDetail.Example]
    let onChunkReaderTapped: (WordDetail.Example) -> Void
    let onChatBotTapped: (WordDetail.Example) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .background(DesignSystemColor.Border.subtle)
                .padding(.bottom, 22)
            ExamplesSection(
                term: term,
                examples: examples,
                onChunkReaderTapped: onChunkReaderTapped,
                onChatBotTapped: onChatBotTapped
            )
        }
        .padding(.bottom, 24)
    }
}

private struct ExamplesSection: View {
    let term: String
    let examples: [WordDetail.Example]
    let onChunkReaderTapped: (WordDetail.Example) -> Void
    let onChatBotTapped: (WordDetail.Example) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("예문")
                .typography(DesignSystemTypography.Pretendard.bold13)
                .foregroundStyle(DesignSystemColor.Foreground.muted)
            ExampleList(
                term: term,
                examples: examples,
                onChunkReaderTapped: onChunkReaderTapped,
                onChatBotTapped: onChatBotTapped
            )
        }
    }
}

private struct ExampleList: View {
    let term: String
    let examples: [WordDetail.Example]
    let onChunkReaderTapped: (WordDetail.Example) -> Void
    let onChatBotTapped: (WordDetail.Example) -> Void

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(examples) { example in
                WordDetailExampleRow(
                    term: term,
                    example: example,
                    onChunkReaderTapped: onChunkReaderTapped,
                    onChatBotTapped: onChatBotTapped
                )
            }
        }
    }
}
