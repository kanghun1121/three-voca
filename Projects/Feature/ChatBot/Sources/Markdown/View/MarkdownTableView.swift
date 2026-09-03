import SwiftUI

import DesignSystem

/// 표 렌더. 열 수에 따라 폭 정책이 분기된다(스펙 §표):
/// - 2열 → 균등폭
/// - 3열 → 첫 열의 모든 셀이 8자 이하일 때만 66pt 고정폭, 아니면 균등폭
/// - 4열 → 좁은 가로 패딩 자동 적용
struct MarkdownTableView: View {
    let table: MarkdownTable

    private enum WidthMode {
        case equal
        case firstColumnFixed(CGFloat)
    }

    var body: some View {
        VStack(spacing: 0) {
            row(cells: table.headers, isHeader: true)
            ForEach(Array(table.rows.enumerated()), id: \.offset) { index, cells in
                Rectangle()
                    .fill(DesignSystemAsset.borderSubtle.swiftUIColor)
                    .frame(height: 1)
                row(cells: cells, isHeader: false)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(DesignSystemAsset.borderSubtle.swiftUIColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func row(cells: [AttributedString], isHeader: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { columnIndex, cell in
                MarkdownTableCellView(text: cell, isHeader: isHeader, horizontalPadding: horizontalPadding)
                    .frame(maxWidth: columnWidth(at: columnIndex), alignment: .leading)
            }
        }
        .background(isHeader ? DesignSystemAsset.study100.swiftUIColor : Color.clear)
    }

    private func columnWidth(at index: Int) -> CGFloat? {
        guard case .firstColumnFixed(let width) = widthMode, index == 0 else { return .infinity }
        return width
    }

    private var widthMode: WidthMode {
        guard table.columnCount == 3 else { return .equal }
        let firstColumnCells = [table.headers.first].compactMap { $0 } + table.rows.compactMap(\.first)
        let allShort = firstColumnCells.allSatisfy { String($0.characters).count <= 8 }
        return allShort ? .firstColumnFixed(66) : .equal
    }

    private var horizontalPadding: CGFloat {
        table.columnCount == 4 ? 6 : 10
    }
}
