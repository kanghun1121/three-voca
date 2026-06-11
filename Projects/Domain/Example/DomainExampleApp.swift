import SwiftUI

import Domain
import DomainInterface

import Dependencies

@main
struct DomainExampleApp: App {
    init() {
        prepareDependencies {
            $0.homeClient = .liveValue
            $0.sessionClient = .liveValue
            $0.wordClient = .liveValue
            $0.authClient = .liveValue
            $0.authSessionClient = .liveValue
        }
    }

    var body: some Scene {
        WindowGroup {
            ClientListView()
        }
    }
}
