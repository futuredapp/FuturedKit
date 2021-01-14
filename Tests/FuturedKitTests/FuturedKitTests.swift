import XCTest
@testable import FuturedKit

final class FuturedKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FuturedKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
