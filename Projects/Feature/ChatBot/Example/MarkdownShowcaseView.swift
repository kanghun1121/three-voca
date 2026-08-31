import SwiftUI

import DesignSystem
import FeatureChatBot

/// 목업(grammar-longform-full.png)의 "You love me." 응답 전문을 그대로 렌더해 1:1 대조한다.
struct MarkdownShowcaseView: View {
    var body: some View {
        ScrollView {
            MarkdownView(markdown: MarkdownSample.fullResponse)
                .padding(16)
        }
        .background(DesignSystemAsset.background.swiftUIColor)
    }
}
