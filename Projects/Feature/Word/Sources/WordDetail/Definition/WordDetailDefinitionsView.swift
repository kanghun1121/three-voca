import SwiftUI

import DesignSystem
import DomainInterface

struct WordDetailDefinitionsView: View {
    let groups: [WordDetail.DefinitionGroup]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(groups) { group in
                WordDetailDefinitionGroupView(group: group)
            }
        }
    }
}

private struct WordDetailDefinitionGroupView: View {
    let group: WordDetail.DefinitionGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PartOfSpeechChip(label: group.partOfSpeech)
            MeaningList(meanings: group.meanings)
        }
    }
}

private struct MeaningList: View {
    let meanings: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(meanings, id: \.self) { MeaningRow(meaning: $0) }
        }
    }
}

private struct MeaningRow: View {
    let meaning: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(DesignSystemColor.Spectrum.blue)
                .frame(width: 4, height: 4)
                .padding(.top, 11)
            Text(meaning)
                .typography(DesignSystemTypography.Content.wordDefinition)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
        }
    }
}

private struct PartOfSpeechChip: View {
    let label: String

    var body: some View {
        Text(label)
            .typography(DesignSystemTypography.Pretendard.extraBold12)
            .foregroundStyle(DesignSystemColor.Accent.selectedBlue)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(DesignSystemColor.Accent.selectedBlue100)
            .clipShape(.rect(cornerRadius: 6))
    }
}
