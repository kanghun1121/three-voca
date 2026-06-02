import SwiftUI

struct SessionDetailContentView: View {
    let state: SessionDetailPresentationModel
    let onVocabularyListTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SessionHeaderSection(
                    level: state.level,
                    sessionNumber: state.sessionNumber,
                    wordCount: state.wordCount,
                    estimatedDurationMinutes: state.estimatedDurationMinutes,
                    cefrLevel: state.cefrLevel
                )
                RecordCard(record: state.record)
                WordPreviewSection(wordCount: state.wordCount, words: state.words)
                ActionButtonsSection(onVocabularyListTapped: onVocabularyListTapped)
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
    }
}
