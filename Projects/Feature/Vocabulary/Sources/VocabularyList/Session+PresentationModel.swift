import DomainInterface

extension Session {
    func toVocabularyListPresentationModel() -> VocabularyListPresentationModel {
        VocabularyListPresentationModel(
            level: level,
            sessionNumber: sessionNumber,
            wordCount: words.count,
            words: words.map { word in
                VocabularyListPresentationModel.WordRow(
                    id: word.id,
                    term: word.term,
                    pronunciation: word.pronunciation,
                    primaryMeaning: word.definitions.first?.meaning ?? ""
                )
            }
        )
    }
}
