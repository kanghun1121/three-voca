import Foundation

import FeatureHomeInterface

private let lowAccuracyThreshold: Double = 0.7

extension VocabularyLibrary {
    func toHomeViewState(streakDays: Int) -> HomeViewState {
        HomeViewState(
            streakDays: streakDays,
            levels: levels.map { $0.toLevelCardViewState() }
        )
    }
}

private extension LevelSummary {
    func toLevelCardViewState() -> LevelCardViewState {
        LevelCardViewState(
            id: id,
            levelBadgeText: "L\(level)",
            levelBadgeColor: LevelBadgeColor(level: level),
            name: name,
            subtitle: "\(difficulty.replacing("-", with: "·")) · \(completedSessions)/\(totalSessions) 완료",
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
            subtitle: subtitle,
            icon: iconKind
        )
    }

    private var subtitle: String {
        switch status {
        case .completed:
            let pct = accuracy.map { Int(round($0 * 100)) } ?? 0
            if let date = lastStudiedAt {
                return "완료 · \(Self.relativeFormatter.localizedString(for: date, relativeTo: .now)) · 정답률 \(pct)%"
            }
            return "완료 · 정답률 \(pct)%"
        case .notStarted:
            return "시작 전"
        }
    }

    private var iconKind: SessionIconKind {
        switch status {
        case .completed:
            (accuracy ?? 1) < lowAccuracyThreshold ? .completedLow : .completedHigh
        case .notStarted:
            .notStarted
        }
    }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.unitsStyle = .short
        return f
    }()
}

private extension LevelBadgeColor {
    init(level: Int) {
        switch level {
        case 1: self = .level1
        case 2: self = .level2
        case 3: self = .level3
        case 4: self = .level4
        default: self = .unknown
        }
    }
}
