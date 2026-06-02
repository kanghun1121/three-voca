import SwiftUI

struct VocabularyListContentView: View {
    let state: VocabularyListPresentationModel
    let onWordTapped: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VocabularyListHeaderView(
                    level: state.level,
                    sessionNumber: state.sessionNumber,
                    wordCount: state.wordCount
                )
                WordList(words: state.words, onTapped: onWordTapped)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .scrollIndicators(.hidden)
    }
}

private struct WordList: View {
    let words: [VocabularyListPresentationModel.WordRow]
    let onTapped: (String) -> Void

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(words) { word in
                VocabularyWordRow(word: word, onTapped: { onTapped(word.id) })
            }
        }
    }
}
