import SwiftUI

import DesignSystem
import DomainInterface

struct WordDetailPageView: View {
    let viewState: WordDetailViewModel.ViewState?
    let topInset: CGFloat
    let onPronunciationTapped: (String) -> Void
    let onChunkReaderTapped: (WordDetail.Example) -> Void
    let onChatBotTapped: (WordDetail, WordDetail.Example) -> Void

    var body: some View {
        ScrollView {
            switch viewState {
            case .loaded(let state):
                WordDetailContentView(
                    state: state,
                    onPronunciationTapped: onPronunciationTapped,
                    onChunkReaderTapped: onChunkReaderTapped,
                    onChatBotTapped: { example in onChatBotTapped(state, example) }
                )
            case .error(let message):
                Text(message)
                    .foregroundStyle(DesignSystemColor.Foreground.muted)
                    .frame(maxWidth: .infinity)
                    .containerRelativeFrame(.vertical)
            case .loading, nil:
                WordDetailSkeletonContentView()
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("단어 정보 불러오는 중")
            }
        }
        .scrollIndicators(.hidden)
        // 페이지 TabView의 프레임은 네비게이션 바 아래에서 시작한다. 시스템의 상단 스크롤 가장자리 효과는 스크롤 뷰가
        // 바 뒤까지 확장돼 있어야 붙으므로, 페이지를 바 높이만큼 위로 올리고 첫 화면 위치는 상단 여백으로 맞춘다.
        .contentMargins(.top, topInset, for: .scrollContent)
        .padding(.top, -topInset)
        .background(DesignSystemColor.Background.base)
    }
}
