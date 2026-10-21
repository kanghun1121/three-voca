import Foundation

/// `| a | b |` 형태의 파이프 구분 표 줄들을 헤더+행으로 구조화한다.
/// 둘째 줄(`|---|---|` 구분선)은 데이터로 들어가지 않는다.
enum MarkdownTableParser {
    /// `lines`는 표에 속하는 줄만 넘겨받는다(구분선 판별은 `MarkdownBlockParser`가 미리 한다).
    static func parse(_ lines: [String]) -> MarkdownTable? {
        guard lines.count >= 2 else { return nil }

        let headerCells = splitRow(lines[0])
        guard !headerCells.isEmpty else { return nil }

        let dataRows = lines.dropFirst(2).map { row -> [String] in
            var cells = splitRow(row)
            if cells.count < headerCells.count {
                cells += Array(repeating: "", count: headerCells.count - cells.count)
            } else if cells.count > headerCells.count {
                cells = Array(cells.prefix(headerCells.count))
            }
            return cells
        }

        let headers = headerCells.map(MarkdownInlineParser.parse)
        let rows = dataRows.map { row in row.map(MarkdownInlineParser.parse) }
        return MarkdownTable(headers: headers, rows: rows)
    }

    /// 표 구분선(`|---|---|` / `|:---|---:|` 등) 여부를 판별한다.
    static func isSeparatorRow(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("|") else { return false }
        let cells = splitRow(trimmed)
        guard !cells.isEmpty else { return false }
        return cells.allSatisfy { cell in
            let body = cell.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
            return !body.isEmpty && body.allSatisfy { $0 == "-" }
        }
    }

    private static func splitRow(_ line: String) -> [String] {
        var trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("|") { trimmed.removeFirst() }
        if trimmed.hasSuffix("|") { trimmed.removeLast() }
        return trimmed
            .components(separatedBy: "|")
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
