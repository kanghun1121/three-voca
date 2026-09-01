import SwiftUI

import DesignSystem
import DomainInterface

struct HomeContentView: View {
    let state: VocabularyLibrary
    let viewModel: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeTopBar(onTapped: viewModel.ctaTapped)
                MonthlyCalendarCard(viewModel: viewModel)
                    .padding(.top, 18)
                divider
                SelectedDateContextRow(
                    date: viewModel.selectedDate,
                    isToday: viewModel.isSelectedDateToday,
                    recordCount: viewModel.dayState.recordCount
                )
                dayStateContent
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

    @ViewBuilder
    private var dayStateContent: some View {
        switch viewModel.dayState {
        case .today(let records):
            VStack(spacing: 8) {
                StudyCTACard(onTapped: viewModel.ctaTapped)
                    .padding(.horizontal, 24)
                recordList(records)
            }
            .padding(.top, 16)

        case .past(let records):
            recordList(records)
                .padding(.top, 8)

        case .empty(let isFuture):
            EmptyDayView(isFuture: isFuture, onGoToToday: viewModel.selectToday)
        }
    }

    private func recordList(_ records: [DayRecord]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(records) { record in
                RecordRow(record: record) {
                    viewModel.sessionTapped(id: record.sessionID)
                }
            }
        }
    }
}

#Preview {
    HomeContentView(state: .previewFixture, viewModel: HomeViewModel())
}
