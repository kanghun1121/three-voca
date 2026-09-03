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
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                MarkdownBlockView(block: block)
            }
        }
    }
}
