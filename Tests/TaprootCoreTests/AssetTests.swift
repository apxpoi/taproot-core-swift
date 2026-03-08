@testable import TaprootCore
import XCTest

final class AssetTests: XCTestCase {
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

    func testAssetTypeDisplayMetadataIsComplete() {
        for assetType in AssetType.allCases {
            XCTAssertFalse(assetType.displayName.isEmpty)
            XCTAssertFalse(assetType.displayDescription.isEmpty)
            XCTAssertFalse(assetType.displayGroup.rawValue.isEmpty)
            XCTAssertEqual(assetType.id, assetType.rawValue)
        }
    }

    func testAssetTypeRawValuesAreUnique() {
        XCTAssertEqual(
            Set(AssetType.allCases.map(\.rawValue)).count,
            AssetType.allCases.count
        )
    }

    func testAssetTypeDisplayGroupMapping() {
        XCTAssertEqual(AssetType.cash.displayGroup, .liquid)
        XCTAssertEqual(AssetType.bankAccount.displayGroup, .liquid)
        XCTAssertEqual(AssetType.securities.displayGroup, .market)
        XCTAssertEqual(AssetType.crypto.displayGroup, .market)
        XCTAssertEqual(AssetType.realEstate.displayGroup, .tangible)
        XCTAssertEqual(AssetType.commodities.displayGroup, .tangible)
        XCTAssertEqual(AssetType.collectibles.displayGroup, .tangible)
        XCTAssertEqual(AssetType.other.displayGroup, .tangible)
    }

    func testAssetUnitTypeMetadataIsComplete() {
        for unitType in AssetUnitType.allCases {
            XCTAssertFalse(unitType.rawValue.isEmpty)
            XCTAssertEqual(unitType.id, unitType.rawValue)
        }
    }

    func testAssetUnitTypeRawValuesAreUnique() {
        XCTAssertEqual(
            Set(AssetUnitType.allCases.map(\.rawValue)).count,
            AssetUnitType.allCases.count
        )
    }

    func testAssetUnitTypeCodableRoundTrip() throws {
        for unitType in AssetUnitType.allCases {
            let data = try JSONEncoder().encode(unitType)
            let decoded = try JSONDecoder().decode(AssetUnitType.self, from: data)
            XCTAssertEqual(decoded, unitType)
        }
    }

    func testAssetUnitTypeDefaultScaleRecommendations() {
        XCTAssertEqual(AssetUnitType.unit.defaultScale, 0)
        XCTAssertEqual(AssetUnitType.share.defaultScale, 0)
        XCTAssertEqual(AssetUnitType.token.defaultScale, 8)
        XCTAssertEqual(AssetUnitType.gram.defaultScale, 2)
        XCTAssertEqual(AssetUnitType.sqMeter.defaultScale, 1)
        XCTAssertEqual(AssetUnitType.percent.defaultScale, 2)
        XCTAssertEqual(AssetUnitType.other.defaultScale, 0)
    }
}
