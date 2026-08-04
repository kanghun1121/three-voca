import SwiftUI

import DomainInterface

import Dependencies

@Observable
@MainActor
final class AppViewModel {
    var authState: AuthState = .unauthenticated
    var isCheckingSession = true

    @ObservationIgnored @Dependency(\.checkAuthSessionUseCase) private var checkAuthSessionUseCase
    @ObservationIgnored @Dependency(\.observeAuthStateUseCase) private var observeAuthStateUseCase
    @ObservationIgnored @Dependency(\.refreshAuthSessionUseCase) private var refreshAuthSessionUseCase

    private var streamTask: Task<Void, Never>?

    init() {
        authState = checkAuthSessionUseCase.execute() ? .authenticated : .unauthenticated
    }

    func onAppear() {
        guard streamTask == nil else { return }
        streamTask = Task { [weak self] in
            guard let self else { return }
            for await state in observeAuthStateUseCase.execute() {
                authState = state
            }
        }

        Task { [weak self] in
            guard let self else { return }
            await refreshAuthSessionUseCase.execute()
            isCheckingSession = false
        }
    }
}
