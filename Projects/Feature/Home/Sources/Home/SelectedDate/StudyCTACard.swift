import SwiftUI
import UIKit

import DesignSystem

/// 홈의 "학습하러 가기" CTA. 그라데이션 캡슐 + 우측 플레이 원 (핸드오프 시안 B).
struct StudyCTACard: View {
    let onTapped: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTapped()
        } label: {
            Content()
                .padding(.leading, 28)
                .padding(.trailing, 8)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Background())
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("학습하러 가기")
    }

    private struct Background: View {
        var body: some View {
            LinearGradient(
                stops: [
                    .init(color: DesignSystemAsset.ctaGradientStart.swiftUIColor, location: 0),
                    .init(color: DesignSystemAsset.ctaGradientMid.swiftUIColor, location: 0.6),
                    .init(color: DesignSystemAsset.ctaGradientEnd.swiftUIColor, location: 1),
                ],
                startPoint: UnitPoint(x: 0, y: 0.41),
                endPoint: UnitPoint(x: 1, y: 0.59)
            )
            .clipShape(.capsule)
            .shadow(color: DesignSystemAsset.ctaGradientMid.swiftUIColor.opacity(0.225), radius: 7, y: 7)
        }
    }

    private struct Content: View {
        var body: some View {
            HStack {
                Text("학습하러 가기")
                    .homeTypography(.ctaTitle)
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                Spacer()
                PlayButton()
            }
        }
    }

    private struct PlayButton: View {
        var body: some View {
            Image(systemName: "play.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(DesignSystemAsset.ctaIcon.swiftUIColor)
                .offset(x: 1)
                .frame(width: 48, height: 48)
                .background(DesignSystemAsset.white.swiftUIColor, in: .circle)
                .accessibilityHidden(true)
        }
    }

    private struct PressScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }
}
