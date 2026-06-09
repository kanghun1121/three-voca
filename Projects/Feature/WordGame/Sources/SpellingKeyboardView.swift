import SwiftUI

import DesignSystem

struct SpellingKeyboardView: View {
    let onLetter: (Character) -> Void
    let onDelete: () -> Void
    let onConfirm: () -> Void
    let isConfirmEnabled: Bool

    private let row1: [Character] = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
    private let row2: [Character] = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
    private let row3: [Character] = ["z", "x", "c", "v", "b", "n", "m"]

    var body: some View {
        VStack(spacing: 7) {
            LetterRow(letters: row1, padding: .init(top: 0, leading: 3, bottom: 0, trailing: 3), onLetter: onLetter)
            LetterRow(letters: row2, padding: .init(top: 0, leading: 18, bottom: 0, trailing: 18), onLetter: onLetter)

            HStack(spacing: 5) {
                Spacer()
                    .frame(maxWidth: .infinity)
                    .frame(width: 0)
                    .layoutPriority(-1)

                ForEach(row3, id: \.self) { letter in
                    LetterKey(letter: letter, onTap: { onLetter(letter) })
                }

                DeleteKey(onTap: onDelete)
            }
            .padding(.horizontal, 3)

            BottomRow(onConfirm: onConfirm, isConfirmEnabled: isConfirmEnabled)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.18))
    }
}

// MARK: - 행 레이아웃

private struct LetterRow: View {
    let letters: [Character]
    let padding: EdgeInsets
    let onLetter: (Character) -> Void

    var body: some View {
        HStack(spacing: 5) {
            ForEach(letters, id: \.self) { letter in
                LetterKey(letter: letter, onTap: { onLetter(letter) })
            }
        }
        .padding(padding)
    }
}

// MARK: - 일반 글자 키

private struct LetterKey: View {
    let letter: Character
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(String(letter).uppercased())
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 17))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(DesignSystemAsset.white.swiftUIColor.opacity(0.16))
                .clipShape(.rect(cornerRadius: 6))
        }
        .frame(maxWidth: 33)
    }
}

// MARK: - 삭제 키

private struct DeleteKey: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "delete.backward")
                .font(.system(size: 20))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(Color.black.opacity(0.22))
                .clipShape(.rect(cornerRadius: 6))
        }
        .frame(maxWidth: 33 * 1.4)
        .accessibilityLabel("삭제")
    }
}

// MARK: - 하단 행

private struct BottomRow: View {
    let onConfirm: () -> Void
    let isConfirmEnabled: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text("123")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                .frame(width: 78, height: 42)
                .background(Color.black.opacity(0.22))
                .clipShape(.rect(cornerRadius: 6))

            Text("space")
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.white.swiftUIColor.opacity(0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(DesignSystemAsset.white.swiftUIColor.opacity(0.16))
                .clipShape(.rect(cornerRadius: 6))

            Button(action: onConfirm) {
                Text("확인")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                    .foregroundStyle(DesignSystemAsset.white.swiftUIColor)
                    .frame(width: 88, height: 42)
                    .background(DesignSystemAsset.game.swiftUIColor.opacity(isConfirmEnabled ? 1.0 : 0.5))
                    .clipShape(.rect(cornerRadius: 6))
            }
            .disabled(!isConfirmEnabled)
            .accessibilityLabel("확인")
        }
    }
}
