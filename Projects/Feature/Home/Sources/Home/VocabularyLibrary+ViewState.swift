import FeatureHomeInterface
import Foundation

private let lowAccuracyThreshold: Double = 0.7

extension VocabularyLibrary {
    func toHomeViewState() -> HomeViewState {
        HomeViewState(levels: levels.map { $0.toLevelCardViewState() })
    }
}

private extension LevelSummary {
    func toLevelCardViewState() -> LevelCardViewState {
        LevelCardViewState(
            id: id,
            levelBadgeText: "L\(level)",
            levelBadgeColor: LevelBadgeColor(level: level),
            name: name,
            subtitle: "\(difficulty.replacingOccurrences(of: "-", with: "·")) · \(completedSessions)/\(totalSessions)",
            progressRatio: totalSessions == 0 ? 0 : Double(completedSessions) / Double(totalSessions),
            sessions: sessions.map { $0.toSessionRowViewState() }
        )
    }
}

private extension SessionProgress {
    func toSessionRowViewState() -> SessionRowViewState {
        SessionRowViewState(
            id: id,
            title: "Session \(sessionNumber)",
            trailingText: trailingText,
            icon: iconKind
        )
    }

    private var trailingText: String {
        switch status {
        case .completed:
            let pct = accuracy.map { Int(round($0 * 100)) } ?? 0
            return "완료 · \(pct)%"
        case .notStarted:
            return "시작 전"
        }
    }

    private var iconKind: SessionIconKind {
        switch status {
        case .completed:
            if let acc = accuracy, acc < lowAccuracyThreshold {
                return .completedLow
            }
            return .completedHigh
        case .notStarted:
            return .notStarted
        }
    }
}

private extension LevelBadgeColor {
    init(level: Int) {
        switch level {
        case 1: self = .level1
        case 2: self = .level2
        case 3: self = .level3
        default: self = .unknown
        }
    }
}
