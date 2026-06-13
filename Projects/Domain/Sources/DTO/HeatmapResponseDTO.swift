import Foundation

struct HeatmapResponseDTO: Decodable {
    let dailyActivity: [DailyActivityDTO]

    struct DailyActivityDTO: Decodable {
        let date: String
        let sessionsCount: Int
    }
}
