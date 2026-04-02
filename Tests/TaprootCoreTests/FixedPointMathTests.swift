@testable import TaprootCore
import XCTest

final class FixedPointMathTests: XCTestCase {
    func testPow10() {
        XCTAssertEqual(FixedPointMath.pow10(0), Decimal(1))
        XCTAssertEqual(FixedPointMath.pow10(4), Decimal(10000))
    }

    func testMaxSafeDecimalValue() {
        let expected = Decimal(Int64.max) / Decimal(100)
        XCTAssertEqual(FixedPointMath.maxSafeDecimalValue(for: 2), expected)
    }
}
