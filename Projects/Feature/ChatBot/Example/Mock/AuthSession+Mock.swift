import Foundation

import DomainInterface

extension CheckAuthSessionUseCase {
    /// 로그인된 상태. 로그인 필요 팝업이 뜨지 않고 바로 대화할 수 있다.
    static let loggedIn = CheckAuthSessionUseCase(execute: { true })

    /// 로그인되지 않은 상태. 진입 시 로그인 필요 팝업이 뜬다.
    static let loggedOut = CheckAuthSessionUseCase(execute: { false })
}

extension SignInWithAppleUseCase {
    /// 실제 인증 없이 항상 성공하는 로그인.
    static let happyPath = SignInWithAppleUseCase(execute: { _ in .previewFixture })
}
