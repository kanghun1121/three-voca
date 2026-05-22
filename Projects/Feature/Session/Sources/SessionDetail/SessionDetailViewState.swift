import Foundation

struct SessionDetailViewState: Equatable {
    struct Record: Equatable {
        let firstCompletedDateText: String
        let lastStudiedRelativeText: String
        let reviewCountText: String
        let averageAccuracyText: String
    }

    struct WordPreview: Equatable, Identifiable {
        let id: String
        let term: String
        let primaryMeaning: String
    }

    let levelHeader: String
    let title: String
    let subtitle: String
    let record: Record?
    let wordsSectionTitle: String
    let previewItems: [WordPreview]
    let moreText: String?
}
