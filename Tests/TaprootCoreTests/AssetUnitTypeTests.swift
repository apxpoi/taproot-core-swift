import Iso3166
@testable import TaprootCore
import XCTest

final class AssetUnitTypeTests: XCTestCase {
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
            .ping: "ping",
            .sqFoot: "sqFoot",
            .sqMeter: "sqMeter",
            .acre: "acre",
            .hectare: "hectare",
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
        XCTAssertEqual(AssetUnitType.ping.displayGroup, .tangible)
        XCTAssertEqual(AssetUnitType.sqFoot.displayGroup, .tangible)
        XCTAssertEqual(AssetUnitType.sqMeter.displayGroup, .tangible)
        XCTAssertEqual(AssetUnitType.acre.displayGroup, .tangible)
        XCTAssertEqual(AssetUnitType.hectare.displayGroup, .tangible)
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
        XCTAssertEqual(AssetUnitType.ping.displayName, "Ping (坪)")
        XCTAssertEqual(AssetUnitType.sqFoot.displayName, "Sq. Foot")
        XCTAssertEqual(AssetUnitType.sqMeter.displayName, "Sq. Meter")
        XCTAssertEqual(AssetUnitType.acre.displayName, "Acre")
        XCTAssertEqual(AssetUnitType.hectare.displayName, "Hectare")
        XCTAssertEqual(AssetUnitType.percent.displayName, "Percent (%)")
        XCTAssertEqual(AssetUnitType.other.displayName, "Other")
    }

    func testAssetUnitTypeDisplayDescriptionsAreSpecific() {
        XCTAssertTrue(AssetUnitType.unit.displayDescription.contains("counted one by one"))
        XCTAssertTrue(AssetUnitType.share.displayDescription.contains("stocks or funds"))
        XCTAssertTrue(AssetUnitType.token.displayDescription.contains("digital assets"))
        XCTAssertTrue(AssetUnitType.gram.displayDescription.contains("grams"))
        XCTAssertTrue(AssetUnitType.ping.displayDescription.contains("ping (坪)"))
        XCTAssertTrue(AssetUnitType.sqFoot.displayDescription.contains("square feet"))
        XCTAssertTrue(AssetUnitType.sqMeter.displayDescription.contains("square meters"))
        XCTAssertTrue(AssetUnitType.acre.displayDescription.contains("acres"))
        XCTAssertTrue(AssetUnitType.hectare.displayDescription.contains("hectares"))
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
        XCTAssertEqual(AssetUnitType.ping.defaultScale, 2)
        XCTAssertEqual(AssetUnitType.sqFoot.defaultScale, 0)
        XCTAssertEqual(AssetUnitType.sqMeter.defaultScale, 1)
        XCTAssertEqual(AssetUnitType.acre.defaultScale, 3)
        XCTAssertEqual(AssetUnitType.hectare.defaultScale, 3)
        XCTAssertEqual(AssetUnitType.percent.defaultScale, 2)
        XCTAssertEqual(AssetUnitType.other.defaultScale, 0)
    }

    func testAssetUnitTypeMeasurementConversionMapIncludesMeasurementUnitsOnly() {
        let expectedUnits: Set<AssetUnitType> = [
            .gram,
            .ping,
            .sqFoot,
            .sqMeter,
            .acre,
            .hectare,
        ]

        XCTAssertEqual(Set(AssetUnitType.measurementConversionMap.keys), expectedUnits)
    }

    func testAssetUnitTypeMeasurementConversionFactorsAreStable() {
        XCTAssertEqual(AssetUnitType.measurementConversionFactor(from: .gram, to: .gram), 1)
        XCTAssertEqual(AssetUnitType.measurementConversionFactor(from: .sqFoot, to: .sqMeter), Decimal(string: "0.09290304"))
        XCTAssertEqual(AssetUnitType.measurementConversionFactor(from: .ping, to: .sqMeter), Decimal(string: "3.3057851239669421487603305785"))
        XCTAssertEqual(AssetUnitType.measurementConversionFactor(from: .acre, to: .sqMeter), Decimal(string: "4046.8564224"))
        XCTAssertEqual(AssetUnitType.measurementConversionFactor(from: .hectare, to: .sqMeter), Decimal(string: "10000"))
        XCTAssertEqual(AssetUnitType.measurementConversionFactor(from: .sqMeter, to: .hectare), Decimal(string: "0.0001"))
    }

    func testAssetUnitTypeMeasurementConversionRejectsCrossDimensionConversion() {
        XCTAssertNil(AssetUnitType.measurementConversionFactor(from: .gram, to: .sqMeter))
        XCTAssertNil(AssetUnitType.measurementConversionFactor(from: .sqMeter, to: .gram))
        XCTAssertNil(AssetUnitType.measurementConversionFactor(from: .unit, to: .sqMeter))
    }

    func testAssetUnitTypeCommonRealEstateAreaUnitsByAlpha2Code() {
        let expectedUnitsByAlpha2Code: [String: [AssetUnitType]] = [
            HongKong.alpha2Code: [.sqFoot, .sqMeter],
            Singapore.alpha2Code: [.sqFoot, .sqMeter],
            UnitedArabEmirates.alpha2Code: [.sqFoot, .sqMeter],
            Japan.alpha2Code: [.ping, .sqMeter],
            Taiwan.alpha2Code: [.ping, .sqMeter],
            Canada.alpha2Code: [.sqFoot, .sqMeter, .acre],
            Australia.alpha2Code: [.sqMeter, .hectare, .acre],
            UnitedKingdom.alpha2Code: [.sqFoot, .sqMeter, .acre, .hectare],
            UnitedStates.alpha2Code: [.sqFoot, .acre],
        ]

        for (alpha2Code, expectedUnits) in expectedUnitsByAlpha2Code {
            XCTAssertEqual(AssetUnitType.commonRealEstateAreaUnits(alpha2Code: alpha2Code), expectedUnits)
        }

        XCTAssertEqual(AssetUnitType.commonRealEstateAreaUnits(alpha2Code: "ZZ"), [.sqMeter])
    }
}
