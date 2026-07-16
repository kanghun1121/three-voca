import SwiftUI

import DesignSystem

struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?
    let onPronunciationTapped: (String) -> Void
    let onChunkReaderTapped: (WordDetailPresentationModel.ExampleRow) -> Void

    var body: some View {
        switch viewState {
        case .loaded(let state):
            ScrollView {
                WordDetailContentView(
                    state: state,
                    onPronunciationTapped: onPronunciationTapped,
                    onChunkReaderTapped: onChunkReaderTapped
                )
            }
            .scrollIndicators(.hidden)
            .background(DesignSystemAsset.background.swiftUIColor)
        case .error(let message):
            ScrollView {
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical)
            }
            .scrollIndicators(.hidden)
            .background(DesignSystemAsset.background.swiftUIColor)
        case .loading, nil:
            WordDetailSkeletonView()
        }
    }
}
