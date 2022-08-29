import XCTest
import FuturedKit

final class ActionTests: XCTestCase {

    func testHasFailed() {
        let action: Action = .failure(MockError.failed)
        XCTAssertTrue(action.hasFailed)
    }

    func testError() {
        let action: Action = .failure(MockError.failed)
        XCTAssertTrue(action.error == MockError.failed)
    }

    func testIsLoading() {
        let action: Action<Error> = .loading
        XCTAssertTrue(action.isLoading)
    }
}
