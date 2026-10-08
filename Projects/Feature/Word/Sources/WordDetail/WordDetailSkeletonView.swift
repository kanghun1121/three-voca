import SwiftUI

import DesignSystem

#Preview {
    WordDetailSkeletonView()
}

struct WordDetailSkeletonView: View {
    var body: some View {
        ScrollView {
            WordDetailSkeletonContentView()
        }
        .scrollIndicators(.hidden)
        .background(DesignSystemColor.Base.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("단어 정보 불러오는 중")
    }
}

struct WordDetailSkeletonContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonHeaderView()
                .padding(.bottom, 22)
            SkeletonDefinitionsView()
                .padding(.bottom, 28)
            SkeletonExamplesView()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
        .redacted(reason: .placeholder)
    }
}

// MARK: - Header

private struct SkeletonHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("promise")
                .typography(DesignSystemTypography.Pretendard.extraBold40)
            SkeletonPronunciationRow()
                .padding(.top, 8)
        }
    }
}

private struct SkeletonPronunciationRow: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("/ˈprɒm.ɪs/")
                .typography(DesignSystemTypography.Mono.regular14)
            Circle()
                .frame(width: 32, height: 32)
        }
    }
}

// MARK: - Definitions

private struct SkeletonDefinitionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(0..<2, id: \.self) { _ in
                SkeletonDefinitionGroupView()
            }
        }
    }
}

private struct SkeletonDefinitionGroupView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("동사")
                .typography(DesignSystemTypography.Pretendard.extraBold12)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(DesignSystemColor.Accent.selectedBlue100)
                .clipShape(.rect(cornerRadius: 6))
            SkeletonMeaningList()
        }
    }
}

private struct SkeletonMeaningList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<2, id: \.self) { _ in
                SkeletonMeaningRow()
            }
        }
    }
}

private struct SkeletonMeaningRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .frame(width: 4, height: 4)
                .padding(.top, 11)
            Text("약속하다, 다짐하다")
                .typography(DesignSystemTypography.Content.wordDefinition)
        }
    }
}

// MARK: - Examples

private struct SkeletonExamplesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .background(DesignSystemColor.Border.subtle)
                .padding(.bottom, 22)
            SkeletonExamplesSection()
        }
    }
}

private struct SkeletonExamplesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("예문")
                .typography(DesignSystemTypography.Pretendard.bold13)
            SkeletonExampleList()
        }
    }
}

private struct SkeletonExampleList: View {
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { _ in
                SkeletonExampleRow()
            }
        }
    }
}

private struct SkeletonExampleRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("I promise I will call you tomorrow.")
                .typography(DesignSystemTypography.Pretendard.semiBold16)
            Text("나는 내일 너에게 전화할 것을 약속해.")
                .typography(DesignSystemTypography.Pretendard.regular13)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystemColor.Base.white)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(DesignSystemColor.Border.default, lineWidth: 1)
        }
    }
}
