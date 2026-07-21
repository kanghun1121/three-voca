import SwiftUI

import DesignSystem

struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?
    let onPronunciationTapped: (String) -> Void
    let onChunkReaderTapped: (WordDetailPresentationModel.ExampleRow) -> Void

    var body: some View {
        ScrollView {
            switch viewState {
            case .loaded(let state):
                WordDetailContentView(
                    state: state,
                    onPronunciationTapped: onPronunciationTapped,
                    onChunkReaderTapped: onChunkReaderTapped
                )
            case .error(let message):
                ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical)
            case .loading, nil:
                WordDetailSkeletonContentView()
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("단어 정보 불러오는 중")
            }
        }
        .scrollIndicators(.hidden)
        .background(DesignSystemAsset.background.swiftUIColor)
    }
}
