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

    func testAssetTypeDisplayMetadataIsComplete() {
        for assetType in AssetType.allCases {
            XCTAssertFalse(assetType.displayName.isEmpty)
            XCTAssertFalse(assetType.displayDescription.isEmpty)
            XCTAssertFalse(assetType.displayGroup.rawValue.isEmpty)
            XCTAssertEqual(assetType.id, String(describing: assetType))
        }
    }

    func testAssetTypeRawValuesAreUnique() {
        XCTAssertEqual(
            Set(AssetType.allCases.map(\.rawValue)).count,
            AssetType.allCases.count
        )
    }

    func testAssetTypeIDsRoundTripThroughRawValueLookup() {
        for assetType in AssetType.allCases {
            XCTAssertEqual(AssetType(rawValue: assetType.id), assetType)
        }
    }

    func testAssetTypeDisplayGroupMapping() {
        XCTAssertEqual(AssetType.cash.displayGroup, .liquid)
        XCTAssertEqual(AssetType.bankAccount.displayGroup, .liquid)
        XCTAssertEqual(AssetType.securities.displayGroup, .market)
        XCTAssertEqual(AssetType.crypto.displayGroup, .market)
        XCTAssertEqual(AssetType.realEstate.displayGroup, .tangible)
        XCTAssertEqual(AssetType.commodities.displayGroup, .tangible)
        XCTAssertEqual(AssetType.collectibles.displayGroup, .tangible)
        XCTAssertEqual(AssetType.other.displayGroup, .other)
    }

    func testAssetTypeDisplayGroupUsesCaseNameAsID() {
        XCTAssertEqual(AssetTypeDisplayGroup.liquid.id, "liquid")
        XCTAssertEqual(AssetTypeDisplayGroup.market.id, "market")
        XCTAssertEqual(AssetTypeDisplayGroup.tangible.id, "tangible")
        XCTAssertEqual(AssetTypeDisplayGroup.other.id, "other")

        for displayGroup in AssetTypeDisplayGroup.allCases {
            XCTAssertEqual(displayGroup.id, String(describing: displayGroup))
        }

        XCTAssertNotEqual(AssetTypeDisplayGroup.liquid.id, AssetTypeDisplayGroup.liquid.rawValue)
    }

    func testAssetUnitTypeMetadataIsComplete() {
        for unitType in AssetUnitType.allCases {
            XCTAssertFalse(unitType.rawValue.isEmpty)
            XCTAssertEqual(unitType.id, String(describing: unitType))
        }
    }

    func testAssetUnitTypeRawValuesAreUnique() {
        XCTAssertEqual(
            Set(AssetUnitType.allCases.map(\.rawValue)).count,
            AssetUnitType.allCases.count
        )
    }

    func testAssetUnitTypeIDsUseCaseNamesInsteadOfDisplayLabels() {
        let expectedIDs: [AssetUnitType: String] = [
            .unit: "unit",
            .share: "share",
            .token: "token",
            .gram: "gram",
            .sqMeter: "sqMeter",
            .percent: "percent",
            .other: "other",
        ]

        for (unitType, expectedID) in expectedIDs {
            XCTAssertEqual(unitType.id, expectedID)
            XCTAssertEqual(unitType.id, String(describing: unitType))
            XCTAssertNotEqual(unitType.id, unitType.rawValue)
        }
    }

    func testAssetUnitTypeDisplayMetadataIsComplete() {
        for unitType in AssetUnitType.allCases {
            XCTAssertFalse(unitType.displayName.isEmpty)
            XCTAssertFalse(unitType.displayDescription.isEmpty)
            XCTAssertFalse(unitType.displayGroup.rawValue.isEmpty)
            XCTAssertEqual(unitType.displayName, unitType.rawValue)
        }
    }

    func testAssetUnitTypeDisplayGroupMapping() {
        XCTAssertEqual(AssetUnitType.unit.displayGroup, .liquid)
        XCTAssertEqual(AssetUnitType.share.displayGroup, .market)
        XCTAssertEqual(AssetUnitType.token.displayGroup, .market)
        XCTAssertEqual(AssetUnitType.gram.displayGroup, .tangible)
        XCTAssertEqual(AssetUnitType.sqMeter.displayGroup, .tangible)
        XCTAssertEqual(AssetUnitType.percent.displayGroup, .market)
        XCTAssertEqual(AssetUnitType.other.displayGroup, .other)
    }

    func testAssetUnitTypeDisplayGroupUsesCaseNameAsID() {
        XCTAssertEqual(AssetUnitType.unit.displayGroup.id, "liquid")
        XCTAssertEqual(AssetUnitType.share.displayGroup.id, "market")
        XCTAssertEqual(AssetUnitType.gram.displayGroup.id, "tangible")
        XCTAssertEqual(AssetUnitType.other.displayGroup.id, "other")

        for displayGroup in AssetTypeDisplayGroup.allCases {
            XCTAssertEqual(displayGroup.id, String(describing: displayGroup))
        }
    }

    func testAssetUnitTypeDisplayNamesAreStable() {
        XCTAssertEqual(AssetUnitType.unit.displayName, "Unit")
        XCTAssertEqual(AssetUnitType.share.displayName, "Share")
        XCTAssertEqual(AssetUnitType.token.displayName, "Token")
        XCTAssertEqual(AssetUnitType.gram.displayName, "Gram (g)")
        XCTAssertEqual(AssetUnitType.sqMeter.displayName, "Sq. Meter")
        XCTAssertEqual(AssetUnitType.percent.displayName, "Percent (%)")
        XCTAssertEqual(AssetUnitType.other.displayName, "Other")
    }

    func testAssetUnitTypeDisplayDescriptionsAreSpecific() {
        XCTAssertTrue(AssetUnitType.unit.displayDescription.contains("counted one by one"))
        XCTAssertTrue(AssetUnitType.share.displayDescription.contains("stocks or funds"))
        XCTAssertTrue(AssetUnitType.token.displayDescription.contains("digital assets"))
        XCTAssertTrue(AssetUnitType.gram.displayDescription.contains("grams"))
        XCTAssertTrue(AssetUnitType.sqMeter.displayDescription.contains("square meters"))
        XCTAssertTrue(AssetUnitType.percent.displayDescription.contains("Ownership percentage"))
        XCTAssertTrue(AssetUnitType.other.displayDescription.contains("none of the above fits"))
    }

    func testAssetUnitTypeDisplayGroupCodableRoundTrip() throws {
        for displayGroup in AssetTypeDisplayGroup.allCases {
            let data = try JSONEncoder().encode(displayGroup)
            let decoded = try JSONDecoder().decode(AssetTypeDisplayGroup.self, from: data)
            XCTAssertEqual(decoded, displayGroup)
        }
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
