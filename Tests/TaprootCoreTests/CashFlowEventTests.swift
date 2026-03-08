@testable import TaprootCore
import XCTest

final class CashFlowEventTests: XCTestCase {
    func testDecimalAmountConversion() {
        let event = CashFlowEvent(
            occurredAtUnixMs: 1_772_064_000_000,
            type: .contribution,
            amount: 12_345,
            currency: "USD",
            currencyScale: 2
        )

        XCTAssertEqual(event.decimalAmount, Decimal(string: "123.45"))
    }

    func testValidateRejectsInvalidTimestamp() {
        let event = CashFlowEvent(
            occurredAtUnixMs: 0,
            type: .contribution,
            amount: 100,
            currency: "USD",
            currencyScale: 2
        )

        XCTAssertThrowsError(try event.validate()) { error in
            guard case CashFlowEventValidationError.invalidOccurredAtTimestamp = error else {
                return XCTFail("Expected invalidOccurredAtTimestamp, got: \(error)")
            }
        }
    }

    func testValidateRejectsInvalidAmount() {
        let event = CashFlowEvent(
            occurredAtUnixMs: 1_772_064_000_000,
            type: .withdrawal,
            amount: 0,
            currency: "USD",
            currencyScale: 2
        )

        XCTAssertThrowsError(try event.validate()) { error in
            guard case CashFlowEventValidationError.invalidAmount = error else {
                return XCTFail("Expected invalidAmount, got: \(error)")
            }
        }
    }

    func testValidateRejectsInvalidCurrencyCode() {
        let event = CashFlowEvent(
            occurredAtUnixMs: 1_772_064_000_000,
            type: .withdrawal,
            amount: 100,
            currency: "usd",
            currencyScale: 2
        )

        XCTAssertThrowsError(try event.validate()) { error in
            guard case CashFlowEventValidationError.invalidCurrencyCode = error else {
                return XCTFail("Expected invalidCurrencyCode, got: \(error)")
            }
        }
    }

    func testCodableRoundTrip() throws {
        let accountID = UUID()
        let event = CashFlowEvent(
            occurredAtUnixMs: 1_772_064_000_000,
            type: .contribution,
            amount: 50_000,
            currency: "USD",
            currencyScale: 2,
            accountID: accountID,
            note: "Payday"
        )

        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(CashFlowEvent.self, from: data)

        XCTAssertEqual(decoded, event)
    }
}
