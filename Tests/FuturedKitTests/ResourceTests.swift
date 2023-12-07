import XCTest
import FuturedHelpers

final class ResourceTests: XCTestCase {
    func testHasContent() {
        let content = Bool.random()
        let resource = Resource<Bool, Error>(content: content)
        XCTAssertTrue(resource.hasContent)
    }

    func testContentEquals() {
        let content = Bool.random()
        let resource = Resource<Bool, Error>(content: content)
        XCTAssertEqual(content, resource.content)
    }

    func testHasFailed() {
        let resource = Resource<Bool, Error>(error: MockError.failed)
        XCTAssertTrue(resource.hasFailed)
    }

    func testIsLoading() {
        let resource = Resource<Bool, Error>(isLoading: true)
        XCTAssertTrue(resource.isLoading)
    }

    func testIsRefreshing() {
        let resource = Resource<Bool, Error>(content: Bool.random(), isLoading: true)
        XCTAssertTrue(resource.isRefreshing)
    }
}
