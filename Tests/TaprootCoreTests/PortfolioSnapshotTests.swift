@testable import TaprootCore
import XCTest

final class PortfolioSnapshotTests: XCTestCase {
    func testDecimalTotalValueConversion() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 123_456,
            totalValueScale: 2
        )

        XCTAssertEqual(snapshot.decimalTotalValue, Decimal(string: "1234.56"))
    }

    func testValidateRejectsDuplicateGroupValues() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 10_000,
            totalValueScale: 2,
            groupValues: [
                PortfolioSnapshotGroupValue(group: .market, value: 5_000),
                PortfolioSnapshotGroupValue(group: .market, value: 5_000),
            ]
        )

        XCTAssertThrowsError(try snapshot.validate()) { error in
            guard case PortfolioSnapshotValidationError.duplicateGroupValue = error else {
                return XCTFail("Expected duplicateGroupValue, got: \(error)")
            }
        }
    }

    func testValidateRejectsGroupValueMismatch() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 10_000,
            totalValueScale: 2,
            groupValues: [
                PortfolioSnapshotGroupValue(group: .market, value: 4_000),
                PortfolioSnapshotGroupValue(group: .liquid, value: 5_000),
            ]
        )

        XCTAssertThrowsError(try snapshot.validate()) { error in
            guard case PortfolioSnapshotValidationError.groupValuesDoNotMatchTotal = error else {
                return XCTFail("Expected groupValuesDoNotMatchTotal, got: \(error)")
            }
        }
    }

    func testCodableRoundTrip() throws {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 10_000,
            totalValueScale: 2,
            groupValues: [
                PortfolioSnapshotGroupValue(group: .market, value: 6_000),
                PortfolioSnapshotGroupValue(group: .liquid, value: 4_000),
            ],
            fxRates: [
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "USD",
                    rate: 1_280_000,
                    rateScale: 7,
                    quotedAtUnixMs: 1_772_064_000_000
                ),
            ],
            note: "Month-end"
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(PortfolioSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
    }

    func testSnapshotFXRateDecimalConversion() {
        let rate = SnapshotFXRate(
            fromCurrency: "HKD",
            toCurrency: "USD",
            rate: 1_280_000,
            rateScale: 7,
            quotedAtUnixMs: 1_772_064_000_000
        )

        XCTAssertEqual(rate.decimalRate, Decimal(string: "0.128"))
    }

    func testValidateRejectsDuplicateFXRatePair() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 0,
            totalValueScale: 2,
            fxRates: [
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "USD",
                    rate: 1_280_000,
                    rateScale: 7,
                    quotedAtUnixMs: 1_772_063_000_000
                ),
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "USD",
                    rate: 1_281_000,
                    rateScale: 7,
                    quotedAtUnixMs: 1_772_064_000_000
                ),
            ]
        )

        XCTAssertThrowsError(try snapshot.validate()) { error in
            guard case PortfolioSnapshotValidationError.duplicateFXRatePair = error else {
                return XCTFail("Expected duplicateFXRatePair, got: \(error)")
            }
        }
    }

    func testValidateRejectsFXRateTargetCurrencyMismatch() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 0,
            totalValueScale: 2,
            fxRates: [
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "EUR",
                    rate: 1_280_000,
                    rateScale: 7,
                    quotedAtUnixMs: 1_772_064_000_000
                ),
            ]
        )

        XCTAssertThrowsError(try snapshot.validate()) { error in
            guard case PortfolioSnapshotValidationError.invalidFXRateTargetCurrency = error else {
                return XCTFail("Expected invalidFXRateTargetCurrency, got: \(error)")
            }
        }
    }

    func testValidateRejectsFXRateTimestampAfterSnapshot() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 0,
            totalValueScale: 2,
            fxRates: [
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "USD",
                    rate: 1_280_000,
                    rateScale: 7,
                    quotedAtUnixMs: 1_772_064_000_001
                ),
            ]
        )

        XCTAssertThrowsError(try snapshot.validate()) { error in
            guard case PortfolioSnapshotValidationError.fxRateTimestampAfterSnapshot = error else {
                return XCTFail("Expected fxRateTimestampAfterSnapshot, got: \(error)")
            }
        }
    }

    func testValidateAcceptsSnapshotWithFXRatesAndNoGroupValues() {
        let snapshot = PortfolioSnapshot(
            capturedAtUnixMs: 1_772_064_000_000,
            baseCurrency: "USD",
            totalValue: 0,
            totalValueScale: 2,
            fxRates: [
                SnapshotFXRate(
                    fromCurrency: "HKD",
                    toCurrency: "USD",
                    rate: 1_280_000,
                    rateScale: 7,
                    quotedAtUnixMs: 1_772_064_000_000
                ),
            ]
        )

        XCTAssertNoThrow(try snapshot.validate())
    }
}
