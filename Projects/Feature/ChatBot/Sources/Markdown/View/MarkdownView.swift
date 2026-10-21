import SwiftUI

/// 챗봇 응답 마크다운 부분집합을 렌더링하는 진입점. `init`에서 한 번만 파싱하고,
/// 이후에는 파싱된 블록 배열로만 렌더한다.
public struct MarkdownView: View {
    private let blocks: [MarkdownBlock]

    /// - Parameter fadesTail: true면 마지막 블록의 꼬리 텍스트에 페이드 인 효과를 심는다.
    ///   호출자가 스트리밍 중인지는 이 타입이 알 필요가 없어, 그 판단은 그대로 호출부에 남긴다.
    public init(markdown: String, fadesTail: Bool = false) {
        let parsed = MarkdownBlockParser.parse(markdown)
        blocks = fadesTail ? MarkdownTailFader.fadingTail(of: parsed) : parsed
    }

    public var body: some View {
        // 블록 사이 간격은 MarkdownBlockView가 블록마다 상하 패딩으로 준다 — 여기서는 0.
        //
        // LazyVStack이 아니라 VStack이다. 이 뷰는 채팅 ScrollView 안에 중첩돼, 화면 밖 블록의 높이를
        // 추정값으로 잡는다. 키보드로 스크롤 영역 크기와 오프셋이 바뀔 때마다 실제값과 추정값이
        // 번갈아 보고돼(한 행이 372 ↔ 886pt) 전체 콘텐츠 높이가 흔들리고, 오프셋이 그때마다 다시
        // 보정되며 키보드를 열고 닫을수록 화면이 조금씩 밀렸다. 블록 수는 한 응답 안에서 적다.
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                MarkdownBlockView(block: block)
            }
        }
    }
}
