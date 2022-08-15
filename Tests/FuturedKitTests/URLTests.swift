import XCTest
import FuturedKit

final class URLExpressibleByStringLiteralTests: XCTestCase {
    func testValidStaticStringInitialization() {
        let url: URL = "http://example.org"
        XCTAssertEqual(url.host, "example.org")
    }
}
