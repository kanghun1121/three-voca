import SwiftUI

import DesignSystem

public struct MyPageView: View {
    @State private var viewModel: MyPageViewModel

    public init(viewModel: MyPageViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        GeometryReader { geo in
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
                .frame(maxWidth: .infinity, minHeight: geo.size.height)
            }
        }
        .background(DesignSystemAsset.background.swiftUIColor)
    }
}

#Preview {
    MyPageView(viewModel: MyPageViewModel())
}
