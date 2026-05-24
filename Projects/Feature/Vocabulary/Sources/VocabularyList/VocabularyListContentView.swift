import SwiftUI

struct VocabularyListContentView: View {
    let state: VocabularyListPresentationModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VocabularyListHeaderView(
                        modeLabel: state.modeLabel,
                        wordCountText: state.wordCountText,
                        sessionInfoText: state.sessionInfoText
                    )
                    LazyVStack(spacing: 10) {
                        ForEach(state.words) { word in
                            VocabularyWordRow(word: word)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
            VocabularyListBottomBar(text: state.bottomBarText)
        }
    }
}
