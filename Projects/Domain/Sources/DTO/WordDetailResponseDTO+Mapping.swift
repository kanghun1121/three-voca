import Foundation

import DomainInterface

extension WordDetailResponseDTO {
    func toDomain() -> WordDetail {
        WordDetail(
            id: id,
            term: term,
            level: level,
            pronunciation: pronunciation,
            definitions: definitions.map { $0.toDomain() },
            examples: examples.map { $0.toDomain() }
        )
    }
}

private extension WordDetailResponseDTO.DefinitionDTO {
    func toDomain() -> WordDetail.Definition {
        WordDetail.Definition(
            meaning: meaning,
            partOfSpeech: WordDetail.Definition.PartOfSpeech(rawValue: partOfSpeech) ?? .unknown
        )
    }
}

private extension WordDetailResponseDTO.ExampleDTO {
    func toDomain() -> WordDetail.Example {
        WordDetail.Example(
            en: en,
            ko: ko,
            order: order,
            words: words?.map {
                WordDetail.Example.Word(
                    word: $0.word,
                    meaning: $0.meaning,
                    pos: $0.pos
                )
            },
            chunks: chunks?.map { WordDetail.Example.Chunk(text: $0.text, meaning: $0.meaning) }
        )
    }
}
