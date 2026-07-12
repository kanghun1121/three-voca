import Foundation

extension Date {
    /// activityMap 조회 키로 사용하는 "yyyy-MM-dd" 문자열 표현
    var calendarDateKey: String {
        Self.formatter.string(from: self)
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
