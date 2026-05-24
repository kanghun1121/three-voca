import DomainInterface
import Foundation

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

    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    fileprivate static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .full
        return formatter
    }()
}

private extension Session.Record {
    func toRecordPresentationModel() -> SessionDetailPresentationModel.Record {
        SessionDetailPresentationModel.Record(
            firstCompletedDateText: Session.dateFormatter.string(from: firstCompletedAt),
            lastStudiedRelativeText: Session.relativeFormatter.localizedString(for: lastStudiedAt, relativeTo: Date.now),
            reviewCount: reviewCount,
            averageAccuracyPercent: Int(round(averageAccuracy * 100))
        )
    }
}
