import Foundation

import DomainInterface

import Dependencies

@Observable
@MainActor
final class AppViewModel {
    var authState: AuthState = .checking

    @ObservationIgnored @Dependency(\.authSessionClient) private var authSessionClient
    @ObservationIgnored @Dependency(\.authClient) private var authClient

    func onAppear() {
        Task {
            for await state in authSessionClient.authStateStream() {
                authState = state
            }
        }
        Task {
            await authClient.checkSession()
        }
    }
}
