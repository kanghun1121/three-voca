import SwiftUI

import DesignSystem

@main
struct FiveVocaApp: App {
    @AppStorage(AppearanceMode.storageKey) private var appearanceMode: AppearanceMode = .system

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appearanceMode.colorScheme)
        }
    }
}
