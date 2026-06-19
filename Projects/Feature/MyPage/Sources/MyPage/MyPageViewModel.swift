import Foundation

@Observable
@MainActor
public final class MyPageViewModel {
    public var email = "minji@example.com"

    public init() {}

    func inquiryTapped() {}
    func termsTapped() {}
    func privacyTapped() {}
    func logoutTapped() {}
    func deleteAccountTapped() {}
}
