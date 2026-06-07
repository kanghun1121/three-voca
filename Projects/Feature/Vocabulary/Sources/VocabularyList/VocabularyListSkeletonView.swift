import SwiftUI

import DesignSystem
import Shimmer

struct VocabularyListSkeletonView: View {
    private let rowCount = 8

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SkeletonHeaderView()
                    .padding(.bottom, 22)
                SkeletonWordList(rowCount: rowCount)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .shimmering()
    }
}

private struct SkeletonHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystemAsset.bgSubtle.swiftUIColor)
                .frame(width: 120, height: 16)
            RoundedRectangle(cornerRadius: 6)
                .fill(DesignSystemAsset.bgSubtle.swiftUIColor)
                .frame(width: 80, height: 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(DesignSystemAsset.background.swiftUIColor)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(DesignSystemAsset.border.swiftUIColor, lineWidth: 1)
        }
    }
}

private struct SkeletonWordList: View {
    let rowCount: Int

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(0..<rowCount, id: \.self) { _ in
                SkeletonWordRow()
            }
        }
    }
}

private struct SkeletonWordRow: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystemAsset.bgSubtle.swiftUIColor)
                    .frame(width: 100, height: 18)
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignSystemAsset.bgSubtle.swiftUIColor)
                    .frame(width: 160, height: 13)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(DesignSystemAsset.bgSubtle.swiftUIColor)
                .frame(width: 8, height: 14)
        }
        .padding(16)
        .background(DesignSystemAsset.background.swiftUIColor)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(DesignSystemAsset.border.swiftUIColor, lineWidth: 1)
        }
    }
}
