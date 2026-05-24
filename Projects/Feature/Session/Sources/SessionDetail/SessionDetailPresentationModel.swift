import Foundation

struct SessionDetailPresentationModel: Equatable {
    struct Record: Equatable {
        let firstCompletedDateText: String
        let lastStudiedRelativeText: String
        let reviewCount: Int
        let averageAccuracyPercent: Int
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
    let cefrLevel: String
    let record: Record?
    let words: [WordPreview]
}
