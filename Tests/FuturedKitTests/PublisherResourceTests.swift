import XCTest
import FuturedKit
import Combine

final class PublisherResourceTests: XCTestCase {
    func testOutputHasContent() {
        _ = Just(Bool.random()).resource().sink { resource in
            XCTAssertTrue(resource.hasContent)
        }
    }

    func testOutputContentEquals() {
        let content = Bool.random()
        _ = Just(content).resource().sink { resource in
            XCTAssertEqual(content, resource.content)
        }
    }

    func testOutputContentDidNotFail() {
        let content = Bool.random()
        _ = Just(content).resource().sink { resource in
            XCTAssertFalse(resource.hasFailed)
        }
    }

    func testOutputContentIsNotLoading() {
        let content = Bool.random()
        _ = Just(content).resource().sink { resource in
            XCTAssertFalse(resource.isLoading)
        }
    }

    func testFailureHasFailed() {
        _ = Fail(outputType: Bool.self, failure: ResourceMockError.failed)
            .resource()
            .sink { resource in
                XCTAssertTrue(resource.hasFailed)
            }
    }

    func testFailureHasNoContent() {
        _ = Fail(outputType: Bool.self, failure: ResourceMockError.failed)
            .resource()
            .sink { resource in
                XCTAssertFalse(resource.hasContent)
            }
    }

    func testFailureContentIsNil() {
        _ = Fail(outputType: Bool.self, failure: ResourceMockError.failed)
            .resource()
            .sink { resource in
                XCTAssertEqual(nil, resource.content)
            }
    }

    func testFailureIsNotLoading() {
        _ = Fail(outputType: Bool.self, failure: ResourceMockError.failed)
            .resource()
            .sink { resource in
                XCTAssertFalse(resource.isLoading)
            }
    }
}
