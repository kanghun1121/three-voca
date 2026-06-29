import SwiftUI

import DesignSystem

struct HomeLoadingView: View {
    var body: some View {
        VStack(spacing: 22) {
            HStack(spacing: 12) {
                PulseDot(delay: 0)
                PulseDot(delay: 0.18)
                PulseDot(delay: 0.36)
            }
            .frame(height: 24)
            Text("학습 기록을 불러오는 중")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 13.5))
                .tracking(-0.0675)
                .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystemAsset.bg.swiftUIColor)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("학습 기록을 불러오는 중")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// 1.25s 사이클(0.625s 상승 + 0.625s 하강), 점별 딜레이로 좌→우 파동 연출
// delay: 핸드오프 스태거 0s / 0.18s / 0.36s
private struct PulseDot: View {
    let delay: Double

    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .frame(width: 12, height: 12)
            .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            .scaleEffect(reduceMotion ? 0.62 : (isAnimating ? 1.0 : 0.62))
            .opacity(reduceMotion ? 0.55 : (isAnimating ? 1.0 : 0.28))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(
                    .easeInOut(duration: 0.625)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    HomeLoadingView()
}
