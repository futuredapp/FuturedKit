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

    func testIsLoadingEqual() {
        let action: Action<Error> = .loading
        XCTAssertEqual(action, action)
    }

    func testIsSuccessEqual() {
        let action: Action<Error> = .success
        XCTAssertEqual(action, action)
    }

    func testIsInactiveEqual() {
        let action: Action<Error> = .inactive
        XCTAssertEqual(action, action)
    }

    func testIsFailureEqual() {
        let action: Action<Error> = .failure(MockError.failed)
        XCTAssertEqual(action, action)
    }

    func testIsActionNotEqualSuccessAndLoading() {
        let action1: Action<Error> = .success
        let action2: Action<Error> = .loading
        XCTAssertNotEqual(action1, action2)
    }

    func testIsActionNotEqualFailureAndInactive() {
        let action1: Action<Error> = .failure(MockError.failed)
        let action2: Action<Error> = .inactive
        XCTAssertNotEqual(action1, action2)
    }
}
