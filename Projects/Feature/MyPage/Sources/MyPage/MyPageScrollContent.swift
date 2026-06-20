import SwiftUI

import DesignSystem

struct MyPageScrollContent: View {
    let viewModel: MyPageViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MyPageHeaderView()

                MyPageAccountView(email: viewModel.email)

                MyPageMenuView(
                    onInquiryTapped: viewModel.inquiryTapped,
                    onTermsTapped: viewModel.termsTapped,
                    onPrivacyTapped: viewModel.privacyTapped
                )

                Spacer(minLength: 40)

                MyPageActionsView(onLogoutTapped: viewModel.logoutTapped, onDeleteAccountTapped: viewModel.deleteAccountTapped)
            }
            .frame(maxWidth: .infinity)
            .containerRelativeFrame(.vertical, alignment: .top)
        }
        .background(DesignSystemAsset.background.swiftUIColor)
    }
}
