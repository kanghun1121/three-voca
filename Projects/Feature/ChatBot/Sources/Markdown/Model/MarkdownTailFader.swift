import Foundation

/// 스트리밍 중인 문서의 꼬리 텍스트에 문자 단위 페이드 인 불투명도를 심는다.
/// 어떤 텍스트가 "꼬리"인지는 블록 형태의 지식이라 `MarkdownBlock.replacingTailText(_:)`(모델)에
/// 위임하고, 여기서는 불투명도 커브(길이·최저값·보간 방식)만 소유한다 — 블록 종류가 늘어도
/// 이 타입은 바뀌지 않고, 커브를 바꿔도 블록 쪽은 바뀌지 않는다.
enum MarkdownTailFader {
    /// 페이드를 적용할 꼬리 글자 수.
    private static let length = 12
    /// 가장 최근(마지막) 글자의 불투명도. 그 앞으로 갈수록 1.0에 수렴한다.
    private static let minOpacity = 0.12

    /// 마지막 블록의 꼬리 텍스트에만 문자 단위 불투명도를 심은 새 블록 배열을 만든다.
    /// 빈 배열이면 그대로 반환한다.
    static func fadingTail(of blocks: [MarkdownBlock]) -> [MarkdownBlock] {
        guard let last = blocks.last else { return blocks }
        var updated = blocks
        updated[updated.count - 1] = last.replacingTailText(faded)
        return updated
    }

    /// 텍스트 뒤 `length`글자에 1.0 → `minOpacity` 선형 보간 불투명도를 문자 단위로 스탬프한다.
    /// 글자 수가 `length`보다 짧으면 있는 글자 수만큼만 페이드한다.
    private static func faded(_ text: AttributedString) -> AttributedString {
        var result = text
        let characterCount = text.characters.count
        guard characterCount > 0 else { return result }

        let fadeCount = min(length, characterCount)
        guard let fadeStart = text.characters.index(
            text.endIndex,
            offsetBy: -fadeCount,
            limitedBy: text.startIndex
        ) else { return result }

        // position 0 = 페이드 구간의 첫 글자(가장 먼저 공개돼 거의 불투명), fadeCount-1 = 마지막
        // 글자(방금 도착해 가장 옅음). progress가 0→1로 커질수록 minOpacity 쪽으로 보간한다.
        let denominator = Double(max(fadeCount - 1, 1))
        var index = fadeStart
        var position = 0
        while index < text.endIndex {
            let nextIndex = text.characters.index(after: index)
            let progress = fadeCount == 1 ? 1.0 : Double(position) / denominator
            let opacity = 1.0 - (1.0 - minOpacity) * progress
            result[index..<nextIndex].markdownTailOpacity = opacity
            index = nextIndex
            position += 1
        }

        return result
    }
}
