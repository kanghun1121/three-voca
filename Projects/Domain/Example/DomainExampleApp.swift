import SwiftUI

import Dependencies

import Domain
import DomainInterface

@main
struct DomainExampleApp: App {
    init() {
        prepareDependencies {
            $0.homeClient = .liveValue
            $0.sessionClient = .liveValue
            $0.wordClient = .liveValue
        }
    }

    var body: some Scene {
        WindowGroup {
            ClientListView()
        }
    }
}
