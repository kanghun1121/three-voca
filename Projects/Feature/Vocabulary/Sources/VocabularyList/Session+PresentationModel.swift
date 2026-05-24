import DomainInterface

extension Session {
    func toVocabularyListPresentationModel() -> VocabularyListPresentationModel {
        let hasRecord = record != nil
        let scoreText = hasRecord ? "점수 측정 있음" : "점수 측정 없음"

        return VocabularyListPresentationModel(
            modeLabel: "단어 보기 모드",
            wordCountText: "\(words.count)개 단어",
            sessionInfoText: "Level \(level) · Session \(sessionNumber)",
            bottomBarText: "청록 톤 — \(scoreText)",
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
