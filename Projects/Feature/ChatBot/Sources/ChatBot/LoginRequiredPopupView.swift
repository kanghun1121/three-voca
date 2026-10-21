import AuthenticationServices
import SwiftUI

import DesignSystem

struct LoginRequiredPopupView: View {
    let onAppleRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onAppleCompletion: (Result<ASAuthorization, any Error>) -> Void
    let onTapLater: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("로그인이 필요해요")
                .typography(DesignSystemTypography.Pretendard.extraBold20)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
                .padding(.top, 28)

            Text("이 기능을 사용하려면 로그인해 주세요.")
                .typography(DesignSystemTypography.Pretendard.medium14)
                .foregroundStyle(DesignSystemColor.Foreground.strong.opacity(0.61))
                .padding(.bottom, 24)

            SignInWithAppleButton(
                .signIn,
                onRequest: onAppleRequest,
                onCompletion: onAppleCompletion
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 54)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.horizontal, 26)

            Button(action: onTapLater) {
                Text("나중에")
                    .typography(DesignSystemTypography.Pretendard.medium14)
                    .foregroundStyle(DesignSystemColor.Foreground.strong.opacity(0.28))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .padding(.top, 3)
            .padding(.bottom, 15)
        }
        .frame(maxWidth: .infinity)
        .background(DesignSystemColor.Background.base)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: DesignSystemColor.Foreground.strong.opacity(0.1), radius: 16, x: 0, y: -4)
    }
}
