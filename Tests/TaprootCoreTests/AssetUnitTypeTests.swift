@testable import TaprootCore
import XCTest

final class AssetUnitTypeTests: XCTestCase {
    func testAssetUnitTypeMetadataIsComplete() {
        for unitType in AssetUnitType.allCases {
            XCTAssertFalse(unitType.rawValue.isEmpty)
            XCTAssertEqual(unitType.id, unitType.rawValue)
            XCTAssertEqual(AssetUnitType(id: unitType.id), unitType)
        }
    }

    func testAssetUnitTypeRawValuesAreUnique() {
        XCTAssertEqual(
            Set(AssetUnitType.allCases.map(\.rawValue)).count,
            AssetUnitType.allCases.count
        )
    }

    func testAssetUnitDimensionMetadataIsComplete() {
        for dimension in AssetUnitDimension.allCases {
            XCTAssertFalse(dimension.rawValue.isEmpty)
            XCTAssertEqual(dimension.id, dimension.rawValue)
        }
    }

    func testAssetUnitTypeDimensionsAreStable() {
        XCTAssertEqual(AssetUnitType.unit.dimension, .count)
        XCTAssertEqual(AssetUnitType.share.dimension, .count)
        XCTAssertEqual(AssetUnitType.gram.dimension, .mass)
        XCTAssertEqual(AssetUnitType.ping.dimension, .area)
        XCTAssertEqual(AssetUnitType.sqFoot.dimension, .area)
        XCTAssertEqual(AssetUnitType.sqMeter.dimension, .area)
        XCTAssertEqual(AssetUnitType.acre.dimension, .area)
        XCTAssertEqual(AssetUnitType.hectare.dimension, .area)
        XCTAssertEqual(AssetUnitType.percent.dimension, .ratio)
        XCTAssertEqual(AssetUnitType.other.dimension, .other)
    }

    func testAssetUnitTypeConvertibleMeasurementFlagMatchesDimension() {
        XCTAssertFalse(AssetUnitType.unit.isConvertibleMeasurement)
        XCTAssertFalse(AssetUnitType.share.isConvertibleMeasurement)
        XCTAssertTrue(AssetUnitType.gram.isConvertibleMeasurement)
        XCTAssertTrue(AssetUnitType.sqFoot.isConvertibleMeasurement)
        XCTAssertTrue(AssetUnitType.sqMeter.isConvertibleMeasurement)
        XCTAssertFalse(AssetUnitType.percent.isConvertibleMeasurement)
        XCTAssertFalse(AssetUnitType.other.isConvertibleMeasurement)
    }

    func testAssetUnitTypeCodableRoundTrip() throws {
        for unitType in AssetUnitType.allCases {
            let data = try JSONEncoder().encode(unitType)
            let decoded = try JSONDecoder().decode(AssetUnitType.self, from: data)
            XCTAssertEqual(decoded, unitType)
        }
    }

    func testAssetUnitDimensionCodableRoundTrip() throws {
        for dimension in AssetUnitDimension.allCases {
            let data = try JSONEncoder().encode(dimension)
            let decoded = try JSONDecoder().decode(AssetUnitDimension.self, from: data)
            XCTAssertEqual(decoded, dimension)
        }
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

    func testCustomIdentifierHelpers() {
        XCTAssertEqual(AssetUnitType.customIdentifier(named: "tola"), "custom:tola")
        XCTAssertTrue(AssetUnitType.isCustomIdentifier("custom:tola"))
        XCTAssertTrue(AssetUnitType.isCustomIdentifier(" CUSTOM:TOLA "))
        XCTAssertFalse(AssetUnitType.isCustomIdentifier("custom:"))
        XCTAssertFalse(AssetUnitType.isCustomIdentifier(AssetUnitType.unit.id))
    }
}
