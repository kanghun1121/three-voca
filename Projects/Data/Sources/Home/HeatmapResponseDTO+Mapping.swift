import Foundation

import DomainInterface

extension HeatmapResponseDTO {
    func toDomain() -> [DailyActivity] {
        dailyActivity.map { dto in
            DailyActivity(date: dto.date, sessionsCount: dto.sessionsCount)
        }
    }
}
