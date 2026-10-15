import Foundation

import DomainInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class HomeViewModel {
    @CasePathable
    public enum Destination {
        case lesson(lessonID: String)
        case learningLibrary
    }

    var destination: Destination?

    let today: Date
    private(set) var dayRecordsByDate: [Date: [DayRecord]] = [:]
    private(set) var selectedDate: Date
    @ObservationIgnored private(set) var observationTask: Task<Void, Never>?

    var isSelectedDateToday: Bool { cal.isDate(selectedDate, inSameDayAs: today) }
    var isSelectedDateFuture: Bool { cal.startOfDay(for: selectedDate) > today }
    var selectedDayRecords: [DayRecord] { dayRecordsByDate[cal.startOfDay(for: selectedDate)] ?? [] }
    private var cal: Calendar { .current }
    
    @ObservationIgnored @Dependency(\.learningHistoryRepository) private var learningHistoryRepository
    @ObservationIgnored @Dependency(\.seedRepository) private var seedRepository
    @ObservationIgnored @Dependency(\.learningLibraryRepository) private var learningLibraryRepository

    public init(destination: Destination? = nil) {
        @Dependency(\.date.now) var now
        let today = Calendar.current.startOfDay(for: now)
        self.destination = destination
        self.today = today
        self.selectedDate = today
    }

    public func onAppear() async {
        guard observationTask == nil else { return }

        observationTask = Task {
            for await records in learningHistoryRepository.streamAllCompletions() {
                self.apply(records)
            }
        }
    }
    
    /// 로컬 DB에 시드가 없으면 서버에서 받아온 뒤 학습 라이브러리를 다시 읽게 한다. 실패하면
    /// 화면은 그대로 두고, 홈이 다시 나타날 때 같은 조건으로 재시도된다.
    public func syncSeedIfNeeded() async {
        do {
            try await seedRepository.syncIfNeeded()
            try await learningLibraryRepository.refresh()
        } catch {}
    }

    public func didTapLesson(id: String) {
        destination = .lesson(lessonID: id)
    }

    func didTapDate(_ date: Date) {
        selectedDate = date
    }

    func selectToday() {
        selectedDate = today
    }

    func didTapCTA() {
        destination = .learningLibrary
    }
    
    private func apply(_ records: [LessonCompletionRecord]) {
        dayRecordsByDate = records.dayRecords(calendar: cal)
    }

    deinit {
        observationTask?.cancel()
    }
}
