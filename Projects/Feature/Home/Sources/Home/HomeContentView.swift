import SwiftUI

import DesignSystem
import DomainInterface

struct HomeContentView: View {
    let state: VocabularyLibrary
    let viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeTopBar(onTapped: viewModel.didTapCTA)
                MonthlyCalendarCard(viewModel: viewModel)
                    .padding(.top, 18)
                divider
                SelectedDateContextRow(
                    date: viewModel.selectedDate,
                    isToday: viewModel.isSelectedDateToday,
                    recordCount: viewModel.dayState.recordCount
                )
                DayStateContent(dayState: viewModel.dayState, viewModel: viewModel)
            }
            .padding(.bottom, 40)
        }
        .background(DesignSystemAsset.background.swiftUIColor)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var divider: some View {
        Rectangle()
            .fill(DesignSystemAsset.line.swiftUIColor)
            .frame(height: 1)
            .padding(.horizontal, 24)
            .padding(.top, 34)
    }

    private struct DayStateContent: View {
        let dayState: HomeDayState
        let viewModel: HomeViewModel

        var body: some View {
            switch dayState {
            case .today(let records):
                VStack(spacing: 8) {
                    StudyCTACard(onTapped: viewModel.didTapCTA)
                        .padding(.horizontal, 24)
                    RecordList(records: records, viewModel: viewModel)
                }
                .padding(.top, 16)

            case .past(let records):
                RecordList(records: records, viewModel: viewModel)
                    .padding(.top, 8)

            case .empty(let isFuture):
                EmptyDayView(isFuture: isFuture, onGoToToday: viewModel.selectToday)
            }
        }
    }

    private struct RecordList: View {
        let records: [DayRecord]
        let viewModel: HomeViewModel

        var body: some View {
            LazyVStack(spacing: 0) {
                ForEach(records) { record in
                    RecordRow(record: record) {
                        viewModel.didTapSession(id: record.sessionID)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeContentView(state: .previewFixture, viewModel: HomeViewModel())
}
