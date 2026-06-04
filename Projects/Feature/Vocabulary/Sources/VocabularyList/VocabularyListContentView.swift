import SwiftUI

struct VocabularyListContentView: View {
    let state: VocabularyListPresentationModel
    let onWordTapped: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VocabularyListHeaderView(
                    level: state.level,
                    sessionNumber: state.sessionNumber,
                    wordCount: state.wordCount
                )
                .padding(.bottom, 22)
                WordList(words: state.words, onTapped: onWordTapped)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

private struct WordList: View {
    let words: [VocabularyListPresentationModel.WordRow]
    let onTapped: (String) -> Void

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(words) { word in
                VocabularyWordRow(word: word, onTapped: { onTapped(word.id) })
            }
        }
    }
}
