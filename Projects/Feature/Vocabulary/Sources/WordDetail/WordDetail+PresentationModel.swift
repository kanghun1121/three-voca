import DomainInterface

extension WordDetail {
    func toWordDetailPresentationModel() -> WordDetailPresentationModel {
        WordDetailPresentationModel(
            term: term,
            pronunciation: pronunciation,
            definitionGroups: groupedDefinitions(),
            examples: examples
                .sorted { $0.order < $1.order }
                .map { WordDetailPresentationModel.ExampleRow(id: $0.order, en: $0.en, ko: $0.ko) }
        )
    }
}

private extension WordDetail {
    func groupedDefinitions() -> [WordDetailPresentationModel.DefinitionGroup] {
        var seen: [Definition.PartOfSpeech: Int] = [:]
        var groups: [WordDetailPresentationModel.DefinitionGroup] = []

        for definition in definitions {
            let label = definition.partOfSpeech.koreanLabel
            if let index = seen[definition.partOfSpeech] {
                let existing = groups[index]
                groups[index] = WordDetailPresentationModel.DefinitionGroup(
                    partOfSpeech: existing.partOfSpeech,
                    meanings: existing.meanings + [definition.meaning]
                )
            } else {
                seen[definition.partOfSpeech] = groups.count
                groups.append(
                    WordDetailPresentationModel.DefinitionGroup(
                        partOfSpeech: label,
                        meanings: [definition.meaning]
                    )
                )
            }
        }
        return groups
    }
}

private extension WordDetail.Definition.PartOfSpeech {
    var koreanLabel: String {
        switch self {
        case .noun:         return "명사"
        case .verb:         return "동사"
        case .adjective:    return "형용사"
        case .adverb:       return "부사"
        case .preposition:  return "전치사"
        case .conjunction:  return "접속사"
        case .interjection: return "감탄사"
        case .pronoun:      return "대명사"
        case .unknown:      return "기타"
        }
    }
}
