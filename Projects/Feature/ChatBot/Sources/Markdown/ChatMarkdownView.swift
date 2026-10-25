import SwiftUI

import MarkdownRenderer

/// 챗봇 응답 마크다운. `MarkdownRenderer`에 앱 디자인 시스템 테마를 연결한 진입점이다.
public struct ChatMarkdownView: View {
    private let markdown: String
    private let fadesTail: Bool

    public init(markdown: String, fadesTail: Bool = false) {
        self.markdown = markdown
        self.fadesTail = fadesTail
    }

    public var body: some View {
        MarkdownView(markdown: markdown, fadesTail: fadesTail)
            .markdownTheme(.designSystem)
    }
}
