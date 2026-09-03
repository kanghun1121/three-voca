import SwiftUI

import DesignSystem

/// 구조 도식(` ```structure `). 모노스페이스 + 역할 라벨(`[S]` 형태)만 틸로 강조.
/// 원문을 그대로 보존해야 해서(공백 정렬 유지) 인라인 파싱을 거치지 않는다.
struct MarkdownStructureView: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 11))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(styledLine(line))
                    .font(.system(size: 12.5, design: .monospaced))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemAsset.bgMuted.swiftUIColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(DesignSystemAsset.borderSubtle.swiftUIColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    /// `[S]`, `[V]`, `[목적어 O]`처럼 대괄호로 감싼 역할 라벨만 틸로 칠하고 나머지는 기본색을 쓴다.
    private func styledLine(_ line: String) -> AttributedString {
        var result = AttributedString(line)
        result.foregroundColor = DesignSystemAsset.fg.swiftUIColor

        var searchStart = line.startIndex
        while searchStart < line.endIndex,
              let open = line.range(of: "[", range: searchStart..<line.endIndex),
              let close = line.range(of: "]", range: open.upperBound..<line.endIndex) {
            if let attrRange = Range(open.lowerBound..<close.upperBound, in: result) {
                result[attrRange].foregroundColor = DesignSystemAsset.study300.swiftUIColor
            }
            searchStart = close.upperBound
        }

        return result
    }
}
