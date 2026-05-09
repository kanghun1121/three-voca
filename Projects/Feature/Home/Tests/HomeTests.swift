import XCTest
@testable import FeatureHome

final class HomeTests: XCTestCase {
    func test_initialize_doesNotCrash() {
        _ = Home()
    }
}
