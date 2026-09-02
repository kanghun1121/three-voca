import Foundation

import DomainInterface
import FeatureSession

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class HomeViewModel {
    private(set) var state: VocabularyLibrary?
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?
    private(set) var selectedDate: Date
    private(set) var dayRecordsByDate: [Date: [DayRecord]] = [:]
    var destination: Destination?
    let today: Date

    @ObservationIgnored @Dependency(\.getHomeOverviewUseCase) private var getHomeOverviewUseCase

    private var cal: Calendar { .current }

    var isSelectedDateToday: Bool { cal.isDate(selectedDate, inSameDayAs: today) }

    var dayState: HomeDayState {
        HomeDayState.resolve(
            selectedDate: selectedDate,
            today: today,
            recordsByDate: dayRecordsByDate,
            calendar: cal
        )
    }

    @CasePathable
    public enum Destination {
        case session(SessionDetailViewModel)
        case levelLibrary(LevelLibraryViewModel)
    }

    public init(
        destination: Destination? = nil,
        today: Date = Calendar.current.startOfDay(for: .now)
    ) {
        self.destination = destination
        self.today = today
        self.selectedDate = today
    }

    // MARK: - Home actions

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let library = try await getHomeOverviewUseCase.execute()
            state = library
            dayRecordsByDate = library.dayRecords(calendar: cal)
        } catch {
            errorMessage = "홈 정보를 불러오지 못했습니다."
        }
    }

    func didTapDate(_ date: Date) {
        selectedDate = date
    }

    func selectToday() {
        selectedDate = today
    }

    func didTapCTA() {
        destination = .levelLibrary(LevelLibraryViewModel())
    }

    public func didTapSession(id: String) {
        destination = .session(SessionDetailViewModel(sessionID: id))
    }
}
