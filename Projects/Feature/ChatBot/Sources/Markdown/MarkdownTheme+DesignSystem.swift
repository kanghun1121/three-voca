import SwiftUI

import DesignSystem
import MarkdownRenderer

extension MarkdownTheme {
    /// 앱 디자인 시스템의 색을 마크다운 렌더링에 연결한다. 글꼴은 패키지가 소유한다.
    /// 보조 글자·배경·테두리는 `textColor`·`markdownColor`에서 파생된다.
    static let designSystem = MarkdownTheme(
        textColor: DesignSystemColor.Foreground.default,
        markdownColor: DesignSystemColor.Accent.selectedBlue,
        positiveColor: DesignSystemColor.Status.positive,
        negativeColor: DesignSystemColor.Status.negative
    )
}
