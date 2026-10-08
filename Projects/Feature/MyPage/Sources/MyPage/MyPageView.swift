import SwiftUI

import DesignSystem

import SwiftUINavigation

public struct MyPageView: View {
    @State private var viewModel: MyPageViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(viewModel: MyPageViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var appearanceBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isShowingAppearance },
            set: { if !$0 { viewModel.destination = nil } }
        )
    }

    private var privacySheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isShowingPrivacyWebView },
            set: { if !$0 { viewModel.destination = nil } }
        )
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                MyPageScrollContent(viewModel: viewModel)

                if viewModel.isShowingDeleteSheet {
                    Button {
                        viewModel.closeDeleteSheet()
                    } label: {
                        DesignSystemColor.Foreground.strong.opacity(0.4)
                            .ignoresSafeArea()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("닫기")
                    .transition(.opacity)

                    DeleteAccountConfirmSheet(
                        confirmText: $viewModel.deleteConfirmText,
                        isConfirmed: viewModel.isDeleteConfirmed,
                        onConfirm: viewModel.deleteAccountConfirmTapped,
                        onCancel: viewModel.closeDeleteSheet
                    )
                    .padding(.horizontal, 30)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isShowingDeleteSheet)
            .navigationDestination(isPresented: appearanceBinding) {
                AppearanceSettingView()
            }
        }
        .tint(DesignSystemColor.Foreground.strong)
        .toolbar(viewModel.isShowingAppearance ? .hidden : .visible, for: .tabBar)
        .sheet(isPresented: privacySheetBinding) {
            if let url = viewModel.privacyPolicyURL {
                PrivacyWebView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert($viewModel.destination.alert) { action in
            viewModel.alertButtonTapped(action)
        }
        .tint(DesignSystemColor.Base.white)
        .task { viewModel.onAppear() }
    }
}

#Preview {
    MyPageView(viewModel: MyPageViewModel())
}
