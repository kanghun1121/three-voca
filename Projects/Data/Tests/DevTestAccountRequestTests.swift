#if DEV_ENVIRONMENT
import XCTest

import NetworkingInterface

@testable import Data

final class DevTestAccountRequestTests: XCTestCase {
    func test_password로그인_요청에는_이메일과_비밀번호만_포함한다() throws {
        let sut = DevTestAccountRequest(email: "fixture@example.com", password: "fixture-password")
        let request = try sut.makeURLRequest()
        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(url.path, "/auth/v1/token")
        XCTAssertEqual(components.queryItems, [URLQueryItem(name: "grant_type", value: "password")])
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
        XCTAssertFalse(sut.requiresAuthentication)
        let body = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(json, ["email": "fixture@example.com", "password": "fixture-password"])
    }
}
#endif
