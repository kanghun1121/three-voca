import SwiftUI

import DesignSystem

struct HomeContentView: View {
    let viewModel: HomeViewModel

    @State private var viewportHeight: CGFloat = 0

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
                    recordCount: viewModel.selectedDayRecords.count
                )
                DayStateContent(viewModel: viewModel)
            }
            .padding(.bottom, 40)
            // 기록 없는 날 화면이 남는 공간의 세로 가운데에 놓이도록 콘텐츠 높이를 뷰포트 이상으로 맞춘다.
            .frame(minHeight: viewportHeight, alignment: .top)
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { viewportHeight = $0 }
        .background(DesignSystemColor.Background.base)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var divider: some View {
        Rectangle()
            .fill(DesignSystemColor.Border.subtle)
            .frame(height: 1)
            .padding(.horizontal, 24)
            .padding(.top, 34)
    }

    private struct DayStateContent: View {
        let viewModel: HomeViewModel

        var body: some View {
            if viewModel.isSelectedDateToday {
                VStack(spacing: 8) {
                    StudyCTACard(onTapped: viewModel.didTapCTA)
                        .padding(.horizontal, 24)
                    RecordList(records: viewModel.selectedDayRecords, viewModel: viewModel)
                }
                .padding(.top, 16)
            } else if viewModel.selectedDayRecords.isEmpty {
                EmptyDayView(isFuture: viewModel.isSelectedDateFuture, onGoToToday: viewModel.selectToday)
            } else {
                RecordList(records: viewModel.selectedDayRecords, viewModel: viewModel)
                    .padding(.top, 8)
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
                        viewModel.didTapLesson(id: record.lessonID)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeContentView(viewModel: HomeViewModel())
}
