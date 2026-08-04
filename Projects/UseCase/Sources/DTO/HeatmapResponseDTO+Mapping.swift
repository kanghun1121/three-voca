import Foundation

import UseCaseInterface

extension HeatmapResponseDTO {
    func toDomain() -> [DailyActivity] {
        dailyActivity.map { dto in
            DailyActivity(date: dto.date, sessionsCount: dto.sessionsCount)
        }
    }
}
