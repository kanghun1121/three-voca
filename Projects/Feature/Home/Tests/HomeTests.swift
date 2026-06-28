import XCTest

@testable import FeatureHome

@MainActor
final class CalendarNavigationTests: XCTestCase {

    // 이번 달이 아닐 때 isCalendarAtCurrentMonth == false → 연속 라벨 숨김 조건 충족
    func testStreakHiddenWhenNotAtCurrentMonth() {
        let vm = HomeViewModel()
        vm.calendarPreviousMonth()
        XCTAssertFalse(vm.isCalendarAtCurrentMonth)
    }

    // 이전 달 셰브론 클릭 시 해당 달로 이동
    func testPreviousMonthChevronNavigatesMonth() {
        let june = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!
        let vm = HomeViewModel(calendarToday: june)

        vm.calendarPreviousMonth()

        XCTAssertEqual(vm.calendarYear, 2026)
        XCTAssertEqual(vm.calendarMonth, 5)
    }

    // 현재 달에서 다음 달 셰브론 클릭 시 미래로 이동 불가
    func testNextMonthChevronBlockedAtCurrentMonth() {
        let vm = HomeViewModel()
        XCTAssertTrue(vm.isCalendarAtCurrentMonth)

        vm.calendarNextMonth()

        XCTAssertTrue(vm.isCalendarAtCurrentMonth)
    }
}
