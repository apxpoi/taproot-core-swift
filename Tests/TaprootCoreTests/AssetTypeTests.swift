@testable import TaprootCore
import XCTest

final class AssetTypeTests: XCTestCase {
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

    func testAssetTypeDefaultUnitTypesAreStable() {
        XCTAssertEqual(AssetType.cash.defaultUnitType, .unit)
        XCTAssertEqual(AssetType.bankAccount.defaultUnitType, .unit)
        XCTAssertEqual(AssetType.securities.defaultUnitType, .share)
        XCTAssertEqual(AssetType.crypto.defaultUnitType, .unit)
        XCTAssertEqual(AssetType.realEstate.defaultUnitType, .sqMeter)
        XCTAssertEqual(AssetType.commodities.defaultUnitType, .gram)
        XCTAssertEqual(AssetType.collectibles.defaultUnitType, .unit)
        XCTAssertEqual(AssetType.other.defaultUnitType, .other)
    }

    func testAssetTypeSupportedUnitTypesAreStable() {
        XCTAssertEqual(AssetType.cash.supportedUnitTypes, Set([.unit]))
        XCTAssertEqual(AssetType.bankAccount.supportedUnitTypes, Set([.unit]))
        XCTAssertEqual(AssetType.securities.supportedUnitTypes, Set([.share, .percent, .unit]))
        XCTAssertEqual(AssetType.crypto.supportedUnitTypes, Set([.unit]))
        XCTAssertEqual(AssetType.realEstate.supportedUnitTypes, Set([.unit, .percent, .ping, .sqFoot, .sqMeter, .acre, .hectare]))
        XCTAssertEqual(AssetType.commodities.supportedUnitTypes, Set([.unit, .gram]))
        XCTAssertEqual(AssetType.collectibles.supportedUnitTypes, Set([.unit]))
        XCTAssertEqual(AssetType.other.supportedUnitTypes, Set(AssetUnitType.allCases))
    }

    func testAssetTypeCustomUnitSupportIsIntentional() {
        XCTAssertFalse(AssetType.cash.supportsCustomUnitType)
        XCTAssertFalse(AssetType.bankAccount.supportsCustomUnitType)
        XCTAssertFalse(AssetType.securities.supportsCustomUnitType)
        XCTAssertFalse(AssetType.crypto.supportsCustomUnitType)
        XCTAssertTrue(AssetType.realEstate.supportsCustomUnitType)
        XCTAssertTrue(AssetType.commodities.supportsCustomUnitType)
        XCTAssertTrue(AssetType.collectibles.supportsCustomUnitType)
        XCTAssertTrue(AssetType.other.supportsCustomUnitType)
    }

    func testAssetTypeSupportsUnitTypeUsesCompatibilityRules() {
        XCTAssertTrue(AssetType.securities.supports(unitType: .share))
        XCTAssertTrue(AssetType.securities.supports(unitType: .percent))
        XCTAssertFalse(AssetType.securities.supports(unitType: .gram))
        XCTAssertTrue(AssetType.realEstate.supports(unitType: .acre))
        XCTAssertFalse(AssetType.realEstate.supports(unitType: .gram))
        XCTAssertTrue(AssetType.other.supports(unitType: .gram))
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
}
