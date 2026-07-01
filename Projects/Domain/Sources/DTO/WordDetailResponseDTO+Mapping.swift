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
        WordDetail.Example(en: en, ko: ko, order: order, words: decodedWords(), chunks: decodedChunks())
    }

    func decodedWords() -> [WordDetail.Example.Word]? {
        guard let words, let data = words.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([WordDTO].self, from: data).map {
            WordDetail.Example.Word(word: $0.word, meaning: $0.meaning, pos: $0.pos)
        }
    }

    func decodedChunks() -> [WordDetail.Example.Chunk]? {
        guard let chunks, let data = chunks.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([ChunkDTO].self, from: data).map {
            WordDetail.Example.Chunk(text: $0.text, meaning: $0.meaning)
        }
    }
}
