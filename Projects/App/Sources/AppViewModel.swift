import SwiftUI

import DomainInterface

import Dependencies

@Observable
@MainActor
final class AppViewModel {
    var authState: AuthState = .unauthenticated

    @ObservationIgnored @Dependency(\.authSessionClient) private var authSessionClient
    @ObservationIgnored @Dependency(\.authClient) private var authClient

    private var streamTask: Task<Void, Never>?

    init() {
        authState = (try? authSessionClient.getRefreshToken()) != nil ? .authenticated : .unauthenticated
    }

    func onAppear() {
        guard streamTask == nil else { return }
        streamTask = Task { [weak self] in
            guard let self else { return }
            for await state in authSessionClient.authStateStream() {
                withAnimation(.easeInOut(duration: 0.4)) {
                    authState = state
                }
            }
        }
        
        Task {
            await authClient.checkSession()
        }
    }
}
