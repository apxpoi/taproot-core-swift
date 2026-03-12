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
        XCTAssertEqual(asset.unitType, AssetUnitType.unit.id)
        XCTAssertEqual(asset.normalizedUnitTypeID, AssetUnitType.unit.id)
    }

    func testTypedInitializerDefaultsUnitTypeFromAssetType() {
        let asset = Asset(
            type: .securities,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            symbol: "TAP",
            valuationAtUnixMs: 1_772_064_000_000
        )

        XCTAssertEqual(asset.type, AssetType.securities.id)
        XCTAssertEqual(asset.unitType, AssetType.securities.defaultUnitType.id)
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
            unitType: AssetUnitType.unit.id,
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

    func testValidateAcceptsEmptyStoredUnitTypeForKnownAssetByUsingDefault() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.cash.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: "  "
        )

        XCTAssertEqual(asset.normalizedUnitTypeID, AssetType.cash.defaultUnitType.id)
        XCTAssertEqual(asset.unitTypeDefinition, .unit)
        XCTAssertNoThrow(try asset.validate())
    }

    func testValidateRejectsUnknownBuiltInUnitIdentifier() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.cash.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: "kilogram"
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.invalidUnitType(let unitType) = error else {
                return XCTFail("Expected invalidUnitType, got: \(error)")
            }

            XCTAssertEqual(unitType, "kilogram")
        }
    }

    func testValidateRejectsIncompatibleBuiltInUnitIdentifier() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.securities.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: AssetUnitType.gram.id,
            symbol: "AAPL",
            valuationAtUnixMs: 1_772_064_000_000
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.incompatibleUnitType(let assetType, let unitType) = error else {
                return XCTFail("Expected incompatibleUnitType, got: \(error)")
            }

            XCTAssertEqual(assetType, AssetType.securities.id)
            XCTAssertEqual(unitType, AssetUnitType.gram.id)
        }
    }

    func testValidateAcceptsCustomUnitForCompatibleAssetType() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.realEstate.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 2,
            quantityScale: 0,
            unitType: AssetUnitType.customIdentifier(named: "rai")
        )

        XCTAssertTrue(asset.hasCustomUnitType)
        XCTAssertNoThrow(try asset.validate())
    }

    func testValidateRejectsCustomUnitForIncompatibleAssetType() {
        let asset = Asset(
            id: UUID(),
            type: AssetType.crypto.id,
            value: 100,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: AssetUnitType.customIdentifier(named: "lot"),
            symbol: "BTC",
            valuationAtUnixMs: 1_772_064_000_000
        )

        XCTAssertThrowsError(try asset.validate()) { error in
            guard case AssetValidationError.incompatibleUnitType(let assetType, let unitType) = error else {
                return XCTFail("Expected incompatibleUnitType, got: \(error)")
            }

            XCTAssertEqual(assetType, AssetType.crypto.id)
            XCTAssertEqual(unitType, AssetUnitType.customIdentifier(named: "lot"))
        }
    }
}
