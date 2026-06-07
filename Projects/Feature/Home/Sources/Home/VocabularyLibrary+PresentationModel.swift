import Foundation

import DomainInterface

private let lowAccuracyThreshold: Double = 0.7

extension VocabularyLibrary {
    func toHomePresentationModel() -> HomePresentationModel {
        HomePresentationModel(streakDays: 0, levels: levels.map { $0.toLevelCardPresentationModel() })
    }
}

private extension LevelSummary {
    func toLevelCardPresentationModel() -> LevelCardPresentationModel {
        LevelCardPresentationModel(
            id: id,
            level: level,
            levelBadgeColor: LevelBadgeColor(level: level),
            name: name,
            difficulty: difficulty,
            completedSessions: completedSessions,
            totalSessions: totalSessions,
            progressRatio: totalSessions == 0 ? 0 : Double(completedSessions) / Double(totalSessions),
            sessions: sessions.map { $0.toSessionRowPresentationModel() }
        )
    }
}

private extension SessionProgress {
    func toSessionRowPresentationModel() -> SessionRowPresentationModel {
        SessionRowPresentationModel(
            id: Int(id) ?? 0,
            sessionNumber: sessionNumber,
            accuracyPercent: accuracy.map { Int(round($0 * 100)) },
            icon: iconKind
        )
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
