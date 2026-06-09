import SwiftUI

import DesignSystem
import FeatureWordGameInterface

struct SpellingView: View {
    let word: GameWord
    @Binding var input: String
    let onConfirm: () -> Void

    private var expectedLetters: [Character] { Array(word.term.lowercased()) }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text("이 뜻의 영어 단어는?")
                    .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.70))

                Text(word.primaryMeaning)
                    .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 28))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            letterTiles
                .padding(.bottom, 32)

            keyboardArea
        }
        .padding(.horizontal, 22)
    }

    private var letterTiles: some View {
        HStack(spacing: 6) {
            ForEach(expectedLetters.indices, id: \.self) { index in
                let inputLetters = Array(input.lowercased())
                let filled = index < inputLetters.count
                let letter = filled ? String(inputLetters[index]) : ""
                let isCurrent = index == inputLetters.count

                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignSystemAsset.white.swiftUIColor.opacity(filled ? 0.2 : 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isCurrent
                                    ? DesignSystemAsset.white.swiftUIColor
                                    : DesignSystemAsset.white.swiftUIColor.opacity(0.28),
                                    lineWidth: isCurrent ? 2 : 1
                                )
                        )
                    Text(letter)
                        .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                        .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                }
                .frame(width: tileSize, height: tileSize)
            }
        }
    }

    private var tileSize: CGFloat {
        let count = CGFloat(expectedLetters.count)
        let available: CGFloat = 350
        let spacing: CGFloat = 6 * (count - 1)
        return min(44, (available - spacing) / count)
    }

    private var keyboardArea: some View {
        // 실제 키보드는 TextField로 가려진 상태에서 올라옴
        // TextField를 숨기고 타일에 입력값을 표시
        ZStack {
            TextField("", text: $input)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(.clear)
                .tint(.clear)
                .frame(height: 1)
                .opacity(0.01)
                .onChange(of: input) { _, newValue in
                    // 단어 길이를 초과하면 자르기
                    if newValue.count > expectedLetters.count {
                        input = String(newValue.prefix(expectedLetters.count))
                    }
                }

            confirmButton
        }
        .padding(.bottom, 24)
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text("확인")
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                .foregroundStyle(DesignSystemAsset.game.swiftUIColor)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(DesignSystemAsset.white.swiftUIColor)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}
