import Foundation

@Observable
@MainActor
final class LoginViewModel {
    var isTermsPresented = false
    var isPrivacyPresented = false

    func termsTapped() {
        isTermsPresented = true
    }

    func privacyTapped() {
        isPrivacyPresented = true
    }
}
