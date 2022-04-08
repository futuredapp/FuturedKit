import XCTest
import FuturedKit
import Combine

final class PublisherResultTests: XCTestCase {
    func testOutput() {
        _ = Just(true).result().sink { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
            case .failure:
                XCTFail()
            }
        }
    }

    func testFailure() {
        _ = Fail<Void, MockError>(error: MockError.failed).result().sink { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, MockError.failed)
            }
        }
    }
}
