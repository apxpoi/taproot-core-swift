@testable import TaprootCore
import XCTest

final class AssetModelTests: XCTestCase {
    func testInitializerDefaultsNoteToEmptyString() {
        let asset = Asset(
            type: "cash",
            value: 100,
            currency: "USD",
            currencyScale: 2
        )

        XCTAssertEqual(asset.note, "")
    }

    func testCodableRoundTripPreservesNote() throws {
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 123_456,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: "unit",
            symbol: "USD",
            note: "Emergency fund"
        )

        let data = try JSONEncoder().encode(asset)
        let decoded = try JSONDecoder().decode(Asset.self, from: data)

        XCTAssertEqual(decoded.note, "Emergency fund")
        XCTAssertEqual(decoded, asset)
    }

    func testDecimalConversions() {
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 123_456,
            currency: "USD",
            currencyScale: 2,
            quantity: 52_310_000,
            quantityScale: 6,
            unitType: "unit"
        )

        XCTAssertEqual(asset.decimalValue, Decimal(string: "1234.56"))
        XCTAssertEqual(asset.decimalQuantity, Decimal(string: "52.31"))
    }

    func testValidateAcceptsInRangeScales() {
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 100,
            currency: "USD",
            currencyScale: TaprootLimitsV1.maxCurrencyScale,
            quantity: 1,
            quantityScale: TaprootLimitsV1.maxQuantityScale,
            unitType: "unit"
        )

        XCTAssertNoThrow(try asset.validate())
    }

    func testValidateRejectsCurrencyScaleOutOfRange() {
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 100,
            currency: "USD",
            currencyScale: TaprootLimitsV1.maxCurrencyScale + 1,
            quantity: 1,
            quantityScale: 0,
            unitType: "unit"
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.invalidCurrencyScale = error else {
                return XCTFail("Expected invalidCurrencyScale, got: \(error)")
            }
        }
    }

    func testValidateRejectsQuantityScaleOutOfRange() {
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 100,
            currency: "USD",
            currencyScale: 0,
            quantity: 1,
            quantityScale: TaprootLimitsV1.maxQuantityScale + 1,
            unitType: "unit"
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.invalidQuantityScale = error else {
                return XCTFail("Expected invalidQuantityScale, got: \(error)")
            }
        }
    }

    func testValidateRejectsMarketAssetWithoutValuationTimestamp() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.securities.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: AssetUnitType.share.id,
            symbol: "AAPL"
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.missingValuationTimestampForMarketAsset = error else {
                return XCTFail("Expected missingValuationTimestampForMarketAsset, got: \(error)")
            }
        }
    }

    func testValidateAcceptsMarketAssetWithValuationTimestamp() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.crypto.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: AssetUnitType.token.id,
            symbol: "BTC",
            valuationAtUnixMs: 1_772_064_000_000
        )

        XCTAssertNoThrow(try asset.validate())
    }

    func testValidateRejectsNonPositiveValuationTimestamp() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.cash.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: AssetUnitType.unit.id,
            valuationAtUnixMs: 0
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.invalidValuationTimestamp = error else {
                return XCTFail("Expected invalidValuationTimestamp, got: \(error)")
            }
        }
    }
}
