import Foundation

/// 파싱된 마크다운 표. `columnCount`는 렌더 시점의 폭 정책(2/3/4열) 분기에 쓰인다.
struct MarkdownTable: Equatable {
    let headers: [AttributedString]
    let rows: [[AttributedString]]

    var columnCount: Int { headers.count }
}
