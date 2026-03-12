import Foundation

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
  case unit
  case share
  case gram
  case ping
  case sqFoot
  case sqMeter
  case acre
  case hectare
  case percent
  case other

  public static let customIdentifierPrefix = "custom:"

  public init?(id: String) {
    self.init(rawValue: id)
  }

  public var id: String {
    return rawValue
  }

  public var dimension: AssetUnitDimension {
    switch self {
    case .unit, .share:
      return .count
    case .gram:
      return .mass
    case .ping, .sqFoot, .sqMeter, .acre, .hectare:
      return .area
    case .percent:
      return .ratio
    case .other:
      return .other
    }
  }

  public var isConvertibleMeasurement: Bool {
    switch dimension {
    case .mass, .area:
      return true
    case .count, .ratio, .other:
      return false
    }
  }

  /// Built-in multipliers to convert measurement quantities between units.
  /// Formula: `valueInTarget = valueInSource * factor`.
  public static var measurementConversionMap: [AssetUnitType: [AssetUnitType: Decimal]] {
    let massUnitBaseFactors: [AssetUnitType: Decimal] = [
      .gram: 1,
    ]

    let areaUnitBaseFactors: [AssetUnitType: Decimal] = [
      .ping: Decimal(string: "3.3057851239669421487603305785")!,
      .sqFoot: Decimal(string: "0.09290304")!,
      .sqMeter: 1,
      .acre: Decimal(string: "4046.8564224")!,
      .hectare: 10000,
    ]

    var conversionMap: [AssetUnitType: [AssetUnitType: Decimal]] = [:]
    conversionMap.merge(buildMeasurementConversionMap(from: massUnitBaseFactors), uniquingKeysWith: { _, new in new })
    conversionMap.merge(buildMeasurementConversionMap(from: areaUnitBaseFactors), uniquingKeysWith: { _, new in new })
    return conversionMap
  }

  /// Returns conversion factor from one measurement unit to another when compatible.
  public static func measurementConversionFactor(
    from source: AssetUnitType,
    to target: AssetUnitType
  ) -> Decimal? {
    return measurementConversionMap[source]?[target]
  }

  public static func isCustomIdentifier(_ identifier: String) -> Bool {
    let normalizedIdentifier = identifier
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()

    return normalizedIdentifier.hasPrefix(customIdentifierPrefix)
      && normalizedIdentifier.count > customIdentifierPrefix.count
  }

  public static func customIdentifier(named name: String) -> String {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    return customIdentifierPrefix + trimmedName
  }

  /// Generates dense conversion factors for units sharing the same base dimension.
  private static func buildMeasurementConversionMap(
    from baseFactors: [AssetUnitType: Decimal]
  ) -> [AssetUnitType: [AssetUnitType: Decimal]] {
    var conversionMap: [AssetUnitType: [AssetUnitType: Decimal]] = [:]

    for (sourceUnit, sourceBaseFactor) in baseFactors {
      var targetFactors: [AssetUnitType: Decimal] = [:]
      for (targetUnit, targetBaseFactor) in baseFactors {
        targetFactors[targetUnit] = sourceBaseFactor / targetBaseFactor
      }
      conversionMap[sourceUnit] = targetFactors
    }

    return conversionMap
  }
}
