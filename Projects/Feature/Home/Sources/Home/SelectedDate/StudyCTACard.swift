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
                    .init(color: DesignSystemColor.Gradient.ctaStart, location: 0),
                    .init(color: DesignSystemColor.Gradient.ctaMid, location: 0.6),
                    .init(color: DesignSystemColor.Gradient.ctaEnd, location: 1),
                ],
                startPoint: UnitPoint(x: 0, y: 0.41),
                endPoint: UnitPoint(x: 1, y: 0.59)
            )
            .clipShape(.capsule)
            .shadow(color: DesignSystemColor.Gradient.ctaMid.opacity(0.225), radius: 7, y: 7)
        }
    }

    private struct Content: View {
        var body: some View {
            HStack {
                Text("학습하러 가기")
                    .typography(DesignSystemTypography.Home.ctaTitle)
                    .foregroundStyle(DesignSystemColor.Base.white)
                Spacer()
                PlayButton()
            }
        }
    }

    private struct PlayButton: View {
        var body: some View {
            Image(systemName: "play.fill")
                .typography(DesignSystemTypography.Pretendard.semiBold17)
                .foregroundStyle(DesignSystemColor.Accent.ctaIcon)
                .offset(x: 1)
                .frame(width: 48, height: 48)
                .background(DesignSystemColor.Base.white, in: .circle)
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
