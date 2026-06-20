import Foundation

import DomainInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class MyPageViewModel {
    public var email = "minji@example.com"

    enum AlertAction {
        case confirmLogout
    }

    @CasePathable
    enum Destination {
        case alert(AlertState<AlertAction>)
        case deleteAccountSheet
    }

    var destination: Destination?
    var deleteConfirmText = ""

    var isDeleteConfirmed: Bool { deleteConfirmText == "회원탈퇴" }
    var isShowingDeleteSheet: Bool {
        if case .deleteAccountSheet = destination { true } else { false }
    }

    @ObservationIgnored @Dependency(\.authSessionClient) private var authSessionClient

    public init() {}

    func inquiryTapped() {}
    func termsTapped() {}
    func privacyTapped() {}

    func logoutTapped() {
        destination = .alert(
            AlertState(
                title: TextState("정말로 로그아웃 하시겠습니까?"),
                buttons: [
                    .destructive(TextState("로그아웃"), action: .send(.confirmLogout)),
                    .cancel(TextState("취소"))
                ]
            )
        )
    }

    func alertButtonTapped(_ action: AlertAction?) {
        switch action {
        case .confirmLogout:
            Task { [weak self] in try? await self?.authSessionClient.clearSession() }
        case .none:
            break
        }
    }

    func deleteAccountTapped() {
        deleteConfirmText = ""
        destination = .deleteAccountSheet
    }

    func closeDeleteSheet() {
        destination = nil
        deleteConfirmText = ""
    }

    func deleteAccountConfirmTapped() {
        destination = nil
        deleteConfirmText = ""
        Task { [weak self] in
            guard let self else { return }
            do {
                try await authSessionClient.deleteAccount()
            } catch {
                destination = .alert(AlertState(
                    title: TextState("탈퇴에 실패했습니다. 다시 시도해 주세요."),
                    buttons: [.cancel(TextState("확인"))]
                ))
            }
        }
    }
}
