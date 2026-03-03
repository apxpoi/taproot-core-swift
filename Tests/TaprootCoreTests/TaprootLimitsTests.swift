@testable import TaprootCore
import XCTest

final class TaprootLimitsTests: XCTestCase {
    func testLimitConstants() {
        XCTAssertEqual(TaprootLimitsV1.minCurrencyScale, 0)
        XCTAssertEqual(TaprootLimitsV1.maxCurrencyScale, 9)
        XCTAssertEqual(TaprootLimitsV1.maxTotalAssetsValue, Decimal(10_000_000_000_000))
        XCTAssertEqual(TaprootLimitsV1.maxMoneyProcessingCharacters, 32)
        XCTAssertEqual(TaprootLimitsV1.maxMoneyDisplayCharacters, 24)
        XCTAssertEqual(TaprootLimitsV1.minQuantityScale, 0)
        XCTAssertEqual(TaprootLimitsV1.maxQuantityScale, 18)
        XCTAssertEqual(TaprootLimitsV1.maxInt64, Int64.max)
        XCTAssertEqual(TaprootLimitsV1.defaultPBKDF2Iterations, 100_000)
    }
}
