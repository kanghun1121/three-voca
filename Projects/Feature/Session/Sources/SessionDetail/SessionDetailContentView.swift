import SwiftUI

import DesignSystem

struct SessionDetailContentView: View {
    let state: SessionDetailPresentationModel
    let onGameTapped: () -> Void
    let onVocabularyListTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SessionHeaderSection(
                    level: state.level,
                    sessionNumber: state.sessionNumber,
                    wordCount: state.wordCount,
                    estimatedDurationMinutes: state.estimatedDurationMinutes
                )
                RecordCard(record: state.record)
                WordPreviewSection(wordCount: state.wordCount, words: state.words)
                ActionButtonsSection(onGameTapped: onGameTapped, onVocabularyListTapped: onVocabularyListTapped)
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
        .background(DesignSystemAsset.background.swiftUIColor)
    }
}
