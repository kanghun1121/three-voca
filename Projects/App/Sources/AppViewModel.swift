import Foundation

import DomainInterface

import Dependencies

@Observable
@MainActor
final class AppViewModel {
    var authState: AuthState = .checking

    @ObservationIgnored @Dependency(\.authSessionClient) private var authSessionClient
    @ObservationIgnored @Dependency(\.authClient) private var authClient

    private var streamTask: Task<Void, Never>?

    func onAppear() {
        guard streamTask == nil else { return }
        streamTask = Task {
            for await state in authSessionClient.authStateStream() {
                authState = state
            }
        }
        Task {
            await authClient.checkSession()
        }
    }
}
