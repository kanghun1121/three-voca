import SwiftUI

import DesignSystem

struct WordDetailContentView: View {
    let state: WordDetailPresentationModel
    let onPronunciationTapped: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                WordDetailHeaderView(
                    term: state.term,
                    pronunciation: state.pronunciation
                ) {
                    onPronunciationTapped(state.term)
                }
                .padding(.bottom, 22)

                WordDetailDefinitionsView(groups: state.definitionGroups)
                    .padding(.bottom, 28)

                if !state.examples.isEmpty {
                    WordDetailExamplesView(term: state.term, examples: state.examples)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(DesignSystemAsset.bg.swiftUIColor)
    }
}
