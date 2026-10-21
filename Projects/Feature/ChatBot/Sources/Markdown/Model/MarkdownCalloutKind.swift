import Foundation

/// 콜아웃 인용(`> [!종류] 제목`)의 종류. 스펙에 정의된 3종만 지원하며,
/// 파서가 모르는 종류를 만나면 예문 인용(exampleQuote)으로 폴백한다.
enum MarkdownCalloutKind: Equatable {
    case key
    case caution
    case tip

    /// `[!핵심]`처럼 대괄호 안에 오는 한글 라벨과의 매핑.
    init?(label: String) {
        switch label {
        case "핵심": self = .key
        case "주의": self = .caution
        case "팁": self = .tip
        default: return nil
        }
    }
}
