import SwiftUI

import DesignSystem
import DomainInterface

struct ChunkView: View {
    let chunk: Indexed<WordDetail.Example.Chunk>
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(chunk.element.text)
                .font(.system(size: 16.5, weight: .medium))
                .tracking(-0.01 * 16.5)
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystemAsset.selectedBlue100.swiftUIColor)
                        .stroke(isSelected ? DesignSystemAsset.selectedBlue.swiftUIColor : .clear, lineWidth: 2)
                }
        }
        // 실제 레이아웃 크기(FlowLayout 계산)는 그대로 유지하면서 탭 가능 영역만 넓힌다.
        .contentShape(.rect(cornerRadius: 8).inset(by: -6))
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
