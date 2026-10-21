import Foundation

/// 챗봇 응답 마크다운 부분집합을 줄 단위로 훑어 `MarkdownBlock` 배열로 변환한다.
/// 아래 순서로 블록 종류를 판별한다(앞선 규칙이 우선):
/// 1. ` ```structure ` 펜스 — 닫는 펜스 또는 EOF까지 원문 줄 보존
/// 2. `####`/`###`/`##`/`#` 헤딩
/// 3. `---` 수평선
/// 4. `>` 인용 런 — 콜아웃(`[!종류] 제목`) 또는 예문 인용으로 분기
/// 5. `|` 표 런 (둘째 줄이 구분선일 때만)
/// 6. `-`/`*` 불릿 런 — `✓`/`✗` 접두 여부로 결과 리스트/일반 불릿 세그먼트 분리
/// 7. `숫자.` 번호 리스트 런
/// 8. 빈 줄 스킵
/// 9. 그 외 — 다음 블록 시작 전까지 문단으로 병합
enum MarkdownBlockParser {
    private static let structureFenceOpen = "```structure"
    private static let structureFenceClose = "```"
    private static let defaultStructureTitle = "문장 구조"

    static func parse(_ markdown: String) -> [MarkdownBlock] {
        let lines = markdown.components(separatedBy: "\n")
        var blocks: [MarkdownBlock] = []
        var index = 0

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix(structureFenceOpen) {
                index = parseStructure(lines, from: index, into: &blocks)
            } else if let heading = parseHeadingLine(trimmed) {
                blocks.append(.heading(level: heading.level, text: MarkdownInlineParser.parse(heading.text)))
                index += 1
            } else if trimmed == "---" {
                blocks.append(.divider)
                index += 1
            } else if trimmed.hasPrefix(">") {
                index = parseQuoteRun(lines, from: index, into: &blocks)
            } else if trimmed.hasPrefix("|"), index + 1 < lines.count, MarkdownTableParser.isSeparatorRow(lines[index + 1]) {
                index = parseTableRun(lines, from: index, into: &blocks)
            } else if bulletMarker(of: line) != nil {
                index = parseBulletRun(lines, from: index, into: &blocks)
            } else if orderedMarker(of: trimmed) != nil {
                index = parseOrderedRun(lines, from: index, into: &blocks)
            } else if trimmed.isEmpty {
                index += 1
            } else {
                index = parseParagraph(lines, from: index, into: &blocks)
            }
        }

        return blocks
    }

    // MARK: - Structure fence

    private static func parseStructure(_ lines: [String], from start: Int, into blocks: inout [MarkdownBlock]) -> Int {
        let openLine = lines[start].trimmingCharacters(in: .whitespaces)
        let rawTitle = openLine.dropFirst(structureFenceOpen.count).trimmingCharacters(in: .whitespaces)
        let title = rawTitle.isEmpty ? defaultStructureTitle : rawTitle

        var index = start + 1
        var contentLines: [String] = []
        while index < lines.count, lines[index].trimmingCharacters(in: .whitespaces) != structureFenceClose {
            contentLines.append(lines[index])
            index += 1
        }
        // index가 lines.count면 닫는 펜스 없이 EOF에 도달한 것 — contentLines는 이미 끝까지 채워짐.
        if index < lines.count { index += 1 } // 닫는 ``` 소비

        blocks.append(.structure(title: title, lines: contentLines))
        return index
    }

    // MARK: - Heading

    private struct HeadingLine {
        let level: Int
        let text: String
    }

    private static func parseHeadingLine(_ trimmed: String) -> HeadingLine? {
        if trimmed.hasPrefix("#### ") {
            return HeadingLine(level: 4, text: String(trimmed.dropFirst(5)))
        } else if trimmed.hasPrefix("### ") {
            return HeadingLine(level: 3, text: String(trimmed.dropFirst(4)))
        } else if trimmed.hasPrefix("## ") {
            return HeadingLine(level: 2, text: String(trimmed.dropFirst(3)))
        } else if trimmed.hasPrefix("# ") {
            return HeadingLine(level: 1, text: String(trimmed.dropFirst(2)))
        }
        return nil
    }

    // MARK: - Quote run (예문 인용 / 콜아웃)

    private static func parseQuoteRun(_ lines: [String], from start: Int, into blocks: inout [MarkdownBlock]) -> Int {
        var index = start
        var content: [String] = []
        while index < lines.count {
            let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix(">") else { break }
            content.append(stripQuoteMarker(trimmed))
            index += 1
        }

        if let (kind, title) = parseCalloutHeader(content.first ?? "") {
            let body = content.dropFirst().filter { !$0.isEmpty }.map(MarkdownInlineParser.parse)
            blocks.append(.callout(kind: kind, title: MarkdownInlineParser.parse(title), body: body))
        } else {
            let english = MarkdownInlineParser.parse(content.first ?? "")
            let korean = content.count > 1 ? MarkdownInlineParser.parse(content[1]) : nil
            blocks.append(.exampleQuote(english: english, korean: korean))
        }

        return index
    }

    private static func stripQuoteMarker(_ trimmed: String) -> String {
        var content = String(trimmed.dropFirst()) // ">" 제거
        if content.hasPrefix(" ") { content.removeFirst() }
        return content
    }

    /// `[!핵심] 제목` 형태를 파싱한다. 알려지지 않은 종류면 nil을 반환해 예문 인용 폴백을 유도한다.
    private static func parseCalloutHeader(_ firstLine: String) -> (MarkdownCalloutKind, String)? {
        guard firstLine.hasPrefix("[!"), let closeBracket = firstLine.firstIndex(of: "]") else { return nil }
        let label = String(firstLine[firstLine.index(firstLine.startIndex, offsetBy: 2)..<closeBracket])
        guard let kind = MarkdownCalloutKind(label: label) else { return nil }
        let title = firstLine[firstLine.index(after: closeBracket)...].trimmingCharacters(in: .whitespaces)
        return (kind, title)
    }

    // MARK: - Table run

    private static func parseTableRun(_ lines: [String], from start: Int, into blocks: inout [MarkdownBlock]) -> Int {
        var index = start
        var tableLines: [String] = []
        while index < lines.count, lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("|") {
            tableLines.append(lines[index])
            index += 1
        }

        if let table = MarkdownTableParser.parse(tableLines) {
            blocks.append(.table(table))
        }
        return index
    }

    // MARK: - Bullet run (일반 불릿 / 결과 대조)

    private struct BulletMarker {
        let depth: Int
        let text: String
    }

    private static func bulletMarker(of line: String) -> BulletMarker? {
        let leadingSpaces = line.prefix { $0 == " " }.count
        let rest = line.trimmingCharacters(in: .whitespaces)
        guard rest.hasPrefix("- ") || rest.hasPrefix("* ") else { return nil }
        let depth = min(1, leadingSpaces / 2)
        return BulletMarker(depth: depth, text: String(rest.dropFirst(2)))
    }

    private static func parseBulletRun(_ lines: [String], from start: Int, into blocks: inout [MarkdownBlock]) -> Int {
        var index = start
        var plainBuffer: [MarkdownListItem] = []
        var resultBuffer: [MarkdownResultItem] = []

        func flushPlain() {
            guard !plainBuffer.isEmpty else { return }
            blocks.append(.bulletList(plainBuffer))
            plainBuffer = []
        }
        func flushResult() {
            guard !resultBuffer.isEmpty else { return }
            blocks.append(.resultList(resultBuffer))
            resultBuffer = []
        }

        while index < lines.count, let marker = bulletMarker(of: lines[index]) {
            if let resultKind = resultKind(of: marker.text) {
                flushPlain()
                let text = String(marker.text.dropFirst(2))
                resultBuffer.append(MarkdownResultItem(kind: resultKind, text: MarkdownInlineParser.parse(text)))
            } else {
                flushResult()
                plainBuffer.append(MarkdownListItem(text: MarkdownInlineParser.parse(marker.text), depth: marker.depth))
            }
            index += 1
        }

        flushPlain()
        flushResult()
        return index
    }

    private static func resultKind(of text: String) -> MarkdownResultItem.Kind? {
        if text.hasPrefix("✓ ") { return .correct }
        if text.hasPrefix("✗ ") { return .incorrect }
        return nil
    }

    // MARK: - Ordered run

    private static func orderedMarker(of trimmed: String) -> String? {
        guard let dotIndex = trimmed.firstIndex(of: ".") else { return nil }
        let prefix = trimmed[trimmed.startIndex..<dotIndex]
        guard !prefix.isEmpty, prefix.allSatisfy(\.isNumber) else { return nil }
        let afterDot = trimmed[trimmed.index(after: dotIndex)...]
        guard afterDot.hasPrefix(" ") else { return nil }
        return String(afterDot.dropFirst())
    }

    private static func parseOrderedRun(_ lines: [String], from start: Int, into blocks: inout [MarkdownBlock]) -> Int {
        var index = start
        var items: [MarkdownListItem] = []

        while index < lines.count {
            let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
            guard let text = orderedMarker(of: trimmed) else { break }
            items.append(MarkdownListItem(text: MarkdownInlineParser.parse(text), depth: 0))
            index += 1
        }

        blocks.append(.orderedList(items))
        return index
    }

    // MARK: - Paragraph

    private static func parseParagraph(_ lines: [String], from start: Int, into blocks: inout [MarkdownBlock]) -> Int {
        var index = start
        var paragraphLines: [String] = []

        while index < lines.count {
            let line = lines[index]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if paragraphLines.isEmpty {
                // 첫 줄은 무조건 소비한다 — 앞선 규칙 어디에도 해당하지 않아 여기로 왔기 때문에,
                // 자기 자신을 다시 "새 블록 시작 신호"로 오인해 되돌아가면 인덱스가 멈춰
                // 무한 루프가 된다(예: 구분선 없는 `|` 단독 줄).
                guard !trimmed.isEmpty else { break }
                paragraphLines.append(trimmed)
                index += 1
                continue
            }

            guard !trimmed.isEmpty,
                  !trimmed.hasPrefix(structureFenceOpen),
                  parseHeadingLine(trimmed) == nil,
                  trimmed != "---",
                  !trimmed.hasPrefix(">"),
                  !trimmed.hasPrefix("|"),
                  bulletMarker(of: line) == nil,
                  orderedMarker(of: trimmed) == nil
            else { break }
            paragraphLines.append(trimmed)
            index += 1
        }

        blocks.append(.paragraph(MarkdownInlineParser.parse(paragraphLines.joined(separator: " "))))
        return index
    }
}
