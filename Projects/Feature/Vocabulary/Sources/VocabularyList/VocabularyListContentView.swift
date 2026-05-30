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
                LazyVStack(spacing: 10) {
                    ForEach(state.words) { word in
                        VocabularyWordRow(word: word, onTapped: { onWordTapped(word.id) })
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .scrollIndicators(.hidden)
    }
}
