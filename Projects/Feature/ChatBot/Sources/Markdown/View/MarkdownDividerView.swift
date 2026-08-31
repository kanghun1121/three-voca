import SwiftUI

import DesignSystem

struct MarkdownDividerView: View {
    var body: some View {
        Rectangle()
            .fill(DesignSystemAsset.borderSubtle.swiftUIColor)
            .frame(height: 1)
            .padding(.vertical, 8)
    }
}
