import Foundation

/// 스트리밍 중 문서 꼬리에 남기는 페이드 인 불투명도(0.0~1.0)를 담는 커스텀 AttributedString 속성.
/// `MarkdownHighlightAttribute`와 같은 방식으로 `MarkdownAttributeScope`에 등록해,
/// 스타일러가 run 하나를 순회하며 다른 인라인 서식과 함께 한 번에 판단할 수 있게 한다.
enum MarkdownTailOpacityAttribute: AttributedStringKey {
    typealias Value = Double
    static let name = "markdownTailOpacity"
}
