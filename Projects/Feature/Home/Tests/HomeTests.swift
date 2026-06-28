import XCTest

@testable import FeatureHome

@MainActor
final class CalendarNavigationTests: XCTestCase {

    func test_이전달_이동시_현재달이_아닌_상태가_된다() {
        let vm = HomeViewModel()

        vm.calendarPreviousMonth()

        XCTAssertFalse(vm.isCalendarAtCurrentMonth, "연속 학습 라벨은 현재 달에서만 표시되어야 합니다.")
    }

    func test_이전달_셰브론_클릭시_이전달로_이동된다() {
        let june = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let vm = HomeViewModel(calendarToday: june)

        vm.calendarPreviousMonth()

        XCTAssertEqual(vm.calendarYear, 2026)
        XCTAssertEqual(vm.calendarMonth, 5)
    }

    func test_현재달에서_다음달_셰브론_클릭시_이동이_차단된다() {
        let vm = HomeViewModel()
        XCTAssertTrue(vm.isCalendarAtCurrentMonth)

        vm.calendarNextMonth()

        XCTAssertTrue(vm.isCalendarAtCurrentMonth, "현재 달에서 미래 달로의 이동이 차단되어야 합니다.")
    }
}
