#if DEV_ENVIRONMENT
import XCTest

import DomainInterface

import Dependencies

@testable import Domain

final class SignInWithDevTestAccountUseCaseTests: XCTestCase {
    func test_refreshToken_저장_후에_로그인_상태를_게시한다() async throws {
        let events = LockIsolated<[String]>([])
        let token = AuthToken.previewFixture
        try await withDependencies {
            $0.devTestAccountRepository.signIn = { token }
            $0.authSessionRepository.setRefreshToken = { value in
                XCTAssertEqual(value, token.refreshToken)
                events.withValue { $0.append("refresh") }
            }
            $0.authSessionRepository.setAccessToken = { value in
                XCTAssertEqual(value, token.accessToken)
                events.withValue { $0.append("access") }
            }
        } operation: {
            try await SignInWithDevTestAccountUseCase.liveValue.execute()
        }
        XCTAssertEqual(events.value, ["refresh", "access"])
    }

    func test_refreshToken_저장에_실패하면_로그인_상태를_게시하지_않는다() async {
        let didPublishAccessToken = LockIsolated(false)
        let didThrow = LockIsolated(false)
        await withDependencies {
            $0.devTestAccountRepository.signIn = { .previewFixture }
            $0.authSessionRepository.setRefreshToken = { _ in throw TestError.storageFailure }
            $0.authSessionRepository.setAccessToken = { _ in didPublishAccessToken.setValue(true) }
        } operation: {
            do {
                try await SignInWithDevTestAccountUseCase.liveValue.execute()
            } catch {
                didThrow.setValue(true)
            }
        }
        XCTAssertTrue(didThrow.value)
        XCTAssertFalse(didPublishAccessToken.value)
    }

    private enum TestError: Error {
        case storageFailure
    }
}
#endif
