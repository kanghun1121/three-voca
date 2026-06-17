import DomainInterface

extension Session {
    func toSessionDetailPresentationModel() -> SessionDetailPresentationModel {
        return SessionDetailPresentationModel(
            level: level,
            sessionNumber: sessionNumber,
            wordCount: words.count,
            estimatedDurationMinutes: estimatedDurationMinutes,
            cefrLevel: cefrLevel,
            record: record?.toRecordPresentationModel(),
            words: words.map {
                SessionDetailPresentationModel.WordPreview(
                    id: $0.id,
                    term: $0.term,
                    primaryMeaning: $0.definitions.first?.meaning ?? ""
                )
            }
        )
    }

}

private extension Session.Record {
    func toRecordPresentationModel() -> SessionDetailPresentationModel.Record {
        SessionDetailPresentationModel.Record(
            firstCompletedDateText: firstCompletedAt,
            studyCount: studyCount
        )
    }
}
