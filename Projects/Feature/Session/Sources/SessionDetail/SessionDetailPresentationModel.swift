import Foundation

struct SessionDetailPresentationModel: Equatable {
    struct Record: Equatable {
        let firstCompletedDateText: String
        let studyCount: Int
    }

    struct WordPreview: Equatable, Identifiable {
        let id: String
        let term: String
        let primaryMeaning: String
    }

    let level: Int
    let sessionNumber: Int
    let wordCount: Int
    let estimatedDurationMinutes: Int
    let record: Record?
    let words: [WordPreview]

    static let placeholder = SessionDetailPresentationModel(
        level: 1,
        sessionNumber: 1,
        wordCount: 6,
        estimatedDurationMinutes: 10,
        record: Record(firstCompletedDateText: "2026.05.01", studyCount: 3),
        words: (1...6).map {
            WordPreview(
                id: "\($0)",
                term: "placeholder",
                primaryMeaning: "placeholder"
            )
        }
    )
}
