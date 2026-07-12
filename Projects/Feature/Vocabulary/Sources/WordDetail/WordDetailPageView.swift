import SwiftUI

import DesignSystem

struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?
    let onPronunciationTapped: (String) -> Void
    let onChunkReaderTapped: (WordDetailPresentationModel.ExampleRow) -> Void

    var body: some View {
        Group {
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
            case .error(let message):
                ScrollView {
                    Text(message)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .containerRelativeFrame(.vertical)
                }
                .scrollIndicators(.hidden)
            case .loading, nil:
                WordDetailSkeletonView()
            }
        }
        .background(DesignSystemAsset.background.swiftUIColor)
    }
}
