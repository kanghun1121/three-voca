import DomainInterface
import Foundation

extension Session {
    func toSessionDetailViewState() -> SessionDetailViewState {
        return SessionDetailViewState(
            levelHeader: "LEVEL \(level) · SESSION \(sessionNumber)",
            title: "\(words.count)개 단어",
            subtitle: "약 \(estimatedDurationMinutes)분 소요 · \(cefrLevel) 수준",
            record: record?.toRecordViewState(),
            wordsSectionTitle: "이번 세션의 단어 (\(words.count))",
            words: words.map {
                SessionDetailViewState.WordPreview(
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
    func toRecordViewState() -> SessionDetailViewState.Record {
        SessionDetailViewState.Record(
            firstCompletedDateText: Session.dateFormatter.string(from: firstCompletedAt),
            lastStudiedRelativeText: Session.relativeFormatter.localizedString(for: lastStudiedAt, relativeTo: Date()),
            reviewCountText: "\(reviewCount)회",
            averageAccuracyText: "\(Int(round(averageAccuracy * 100)))%"
        )
    }
}
