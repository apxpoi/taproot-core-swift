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

    func testAssetTypeDisplayNameUsesUserFriendlyTerms() {
        XCTAssertEqual(AssetType.equities.displayName, "Stocks")
        XCTAssertEqual(AssetType.fixedIncome.displayName, "Bonds")
        XCTAssertEqual(AssetType.etfsMutualFunds.displayName, "ETFs & Funds")
        XCTAssertEqual(AssetType.valuablesCollectibles.displayName, "Collectibles")
    }

    func testAssetTypeDisplayMetadataIsComplete() {
        for assetType in AssetType.allCases {
            XCTAssertFalse(assetType.displayName.isEmpty)
            XCTAssertFalse(assetType.displayDescription.isEmpty)
            XCTAssertFalse(assetType.displayGroup.rawValue.isEmpty)
        }
    }
}
