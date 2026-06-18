import SwiftUI

import FeatureMyPage

@main
struct MyPageExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MyPageView(viewModel: MyPageViewModel())
        }
    }
}
