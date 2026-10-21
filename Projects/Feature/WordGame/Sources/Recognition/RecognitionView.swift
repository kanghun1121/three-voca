import SwiftUI

import DesignSystem
import DomainInterface

struct RecognitionView: View {
    let word: Lesson.Word
    let countdown: Int
    let ringProgress: Double
    let isRevealing: Bool
    let onRemembered: () -> Void
    let onForgot: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            RecognitionCenterContent(
                word: word,
                countdown: countdown,
                ringProgress: ringProgress,
                isRevealing: isRevealing
            )

            Spacer()

            RecognitionFooter(
                isRevealing: isRevealing,
                onRemembered: onRemembered,
                onForgot: onForgot
            )
        }
    }
}

// MARK: - 중앙 콘텐츠
// CountdownRingView에 opacity를 적용하여 공개 상태에서도 동일한 공간을 유지,
// 두 상태 간 단어(WordBlock)의 수직 위치를 일정하게 고정한다.

private struct RecognitionCenterContent: View {
    let word: Lesson.Word
    let countdown: Int
    let ringProgress: Double
    let isRevealing: Bool

    var body: some View {
        VStack(spacing: 0) {
            CountdownRingView(countdown: countdown, progress: ringProgress)
                .padding(.bottom, 40)
                .opacity(isRevealing ? 0 : 1)

            // word.id가 바뀔 때 구 단어는 페이드아웃, 새 단어는 페이드인
            // isRevealing 애니메이션 컨텍스트 안에서 실행되므로 타이밍 하드코딩 불필요
            RecognitionWordBlock(word: word)
                .transition(.opacity)
                .id(word.id)
        }
        .frame(maxWidth: .infinity)
        // 뜻은 레이아웃 높이에 포함하지 않고 단어 블록 아래에 띄운다 — 뜻이 몇 줄이든 위쪽(타이머)이 움직이지 않는다.
        .overlay(alignment: .bottom) {
            RecognitionMeaningLabel(text: word.primaryMeaning, isRevealing: isRevealing)
                .transition(.opacity)
                .id(word.id)
                .alignmentGuide(.bottom) { $0[.top] - 24 }
        }
    }
}

// MARK: - 공통 컴포넌트

private struct RecognitionMeaningLabel: View {
    let text: String
    let isRevealing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(text)
            .typography(DesignSystemTypography.Pretendard.semiBold18)
            .foregroundStyle(DesignSystemColor.Base.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(DesignSystemColor.Base.white.opacity(0.12))
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DesignSystemColor.Base.white.opacity(0.28), lineWidth: 1)
            }
            .opacity(isRevealing ? 1 : 0)
            .scaleEffect(isRevealing || reduceMotion ? 1 : 0.95)
    }
}

/// 단어와 발음. 길어서 줄바꿈이 생길 단어는 한 줄에 맞게 글자 크기를 줄이고(화면 너비 기준),
/// 블록 높이는 항상 같게 고정해 위의 타이머 위치가 단어에 따라 달라지지 않게 한다.
private struct RecognitionWordBlock: View {
    let word: Lesson.Word

    var body: some View {
        VStack(spacing: 0) {
            Text(word.term)
                .typography(DesignSystemTypography.Pretendard.extraBold52)
                .foregroundStyle(DesignSystemColor.Base.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)

            Text(word.pronunciation)
                .typography(DesignSystemTypography.Mono.body)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.65))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.top, 12)
        }
        .padding(.horizontal, 24)
        .frame(height: 100, alignment: .top)
    }
}

// MARK: - 하단 버튼

private struct RecognitionFooter: View {
    let isRevealing: Bool
    let onRemembered: () -> Void
    let onForgot: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("3초 안에 뜻이 떠올랐나요?")
                .typography(DesignSystemTypography.Pretendard.regular14)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.70))

            RecognitionJudgmentButtons(
                isRevealing: isRevealing,
                onRemembered: onRemembered,
                onForgot: onForgot
            )
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 40)
        .opacity(isRevealing ? 0 : 1)
    }
}

private struct RecognitionJudgmentButtons: View {
    let isRevealing: Bool
    let onRemembered: () -> Void
    let onForgot: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onForgot) {
                Text("기억 안 나요")
                    .typography(DesignSystemTypography.Pretendard.bold16)
                    .foregroundStyle(DesignSystemColor.Base.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(DesignSystemColor.Base.white.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(DesignSystemColor.Base.white.opacity(0.28), lineWidth: 1)
                    }
            }
            .disabled(isRevealing)

            Button(action: onRemembered) {
                Text("떠올랐어요")
                    .typography(DesignSystemTypography.Pretendard.bold16)
                    .foregroundStyle(DesignSystemColor.Game.base)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(DesignSystemColor.Base.white)
                    .clipShape(.rect(cornerRadius: 18))
            }
            .disabled(isRevealing)
        }
    }
}
