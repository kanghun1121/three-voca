import SwiftUI

import DesignSystem

struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?
    let onPronunciationTapped: (String) -> Void

    var body: some View {
        ScrollView {
            switch viewState {
            case .loaded(let state):
                WordDetailContentView(state: state, onPronunciationTapped: onPronunciationTapped)
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical)
            case .loading, nil:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical)
                    .accessibilityLabel("단어 정보 불러오는 중")
            }
        }
        .scrollIndicators(.hidden)
        .background(DesignSystemAsset.bg.swiftUIColor)
    }
}
