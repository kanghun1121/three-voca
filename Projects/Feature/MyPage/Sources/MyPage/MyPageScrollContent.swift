import SwiftUI

import DesignSystem

struct MyPageScrollContent: View {
    let viewModel: MyPageViewModel
    @AppStorage(AppearanceMode.storageKey) private var appearanceMode: AppearanceMode = .system

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MyPageHeaderView()

                // 로그인 버튼은 지금 단계에서 필요 없어 비로그인 상태에서는 카드를 숨긴다 (기능은 유지)
                if viewModel.isAuthenticated {
                    LoginStatusCardView(
                        isAuthenticated: viewModel.isAuthenticated,
                        onAppleRequest: viewModel.appleLoginRequested,
                        onAppleCompletion: viewModel.appleLoginCompleted
                    )
                }

                MyPageMenuView(viewModel: viewModel, appearanceTitle: appearanceMode.title)

                Spacer(minLength: 40)

                if viewModel.isAuthenticated {
                    MyPageActionsView(onLogoutTapped: viewModel.logoutTapped, onDeleteAccountTapped: viewModel.deleteAccountTapped)
                }
            }
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical, alignment: .top)
        }
        .background(DesignSystemColor.Background.base)
    }
}
