import SwiftUI

import DesignSystem
import DomainInterface

struct LevelList: View {
    let levels: [LevelSummary]
    let onLevelTapped: (String) -> Void

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(levels) { level in
                StageRow(level: level) {
                    onLevelTapped(level.id)
                }
                if level.id != levels.last?.id {
                    Rectangle()
                        .fill(DesignSystemAsset.hairline.swiftUIColor)
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}
