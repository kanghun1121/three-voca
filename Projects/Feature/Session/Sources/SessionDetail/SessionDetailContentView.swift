import SwiftUI

struct SessionDetailContentView: View {
    let state: SessionDetailViewState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SessionHeaderSection(
                    levelHeader: state.levelHeader,
                    title: state.title,
                    subtitle: state.subtitle
                )
                RecordCard(record: state.record)
                WordPreviewSection(
                    title: state.wordsSectionTitle,
                    words: state.words
                )
                ActionButtonsSection()
            }
            .padding(.horizontal, 20)
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
    }
}
