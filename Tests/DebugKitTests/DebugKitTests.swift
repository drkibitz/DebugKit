import XCTest
@testable import DebugKit

final class DebugKitTests: XCTestCase {
    func testExample() {
        if case .textStorage(let storage) = Debug.console {
            XCTAssertNotNil(storage)
        } else {
            XCTAssertTrue(false)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
