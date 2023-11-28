import XCTest
import FuturedKitHelpers
import Combine

final class PublisherResultTests: XCTestCase {
    func testOutput() {
        _ = Just(true).result().sink { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
            case .failure:
                XCTFail("Result should be success")
            }
        }
    }

    func testFailure() {
        _ = Fail<Void, MockError>(error: MockError.failed).result().sink { result in
            switch result {
            case .success:
                XCTFail("Result should be failure")
            case .failure(let error):
                XCTAssertEqual(error, MockError.failed)
            }
        }
    }
}
