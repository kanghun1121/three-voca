import DesignSystem
import SwiftUI

struct WordDetailDefinitionsView: View {
    let groups: [WordDetailPresentationModel.DefinitionGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(groups, id: \.partOfSpeech) { group in
                WordDetailDefinitionGroupView(group: group)
            }
        }
    }
}

private struct WordDetailDefinitionGroupView: View {
    let group: WordDetailPresentationModel.DefinitionGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PartOfSpeechChip(label: group.partOfSpeech)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(group.meanings, id: \.self) { meaning in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                        Text(meaning)
                            .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                    }
                }
            }
        }
    }
}

private struct PartOfSpeechChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
            .foregroundStyle(DesignSystemAsset.primary.swiftUIColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(DesignSystemAsset.study100.swiftUIColor)
            .clipShape(.capsule)
    }
}
