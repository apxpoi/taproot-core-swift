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
