import Foundation
import Iso3166

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
  // Core counting
  case unit = "Unit"
  case share = "Share"
  case token = "Token"

  // Measurements
  case gram = "Gram (g)"
  case ping = "Ping (坪)"
  case sqFoot = "Sq. Foot"
  case sqMeter = "Sq. Meter"
  case acre = "Acre"
  case hectare = "Hectare"

  // Special
  case percent = "Percent (%)"
  case other = "Other"

  public var id: String {
    return String(describing: self)
  }

  public var displayName: String {
    return rawValue
  }

  public var displayGroup: AssetTypeDisplayGroup {
    switch self {
    case .unit:
      return .liquid
    case .share, .token, .percent:
      return .market
    case .gram, .ping, .sqFoot, .sqMeter, .acre, .hectare:
      return .tangible
    case .other:
      return .other
    }
  }

  /// Short helper text for faster unit selection in app UI.
  public var displayDescription: String {
    switch self {
    case .unit:
      return "Generic whole-item quantities counted one by one."
    case .share:
      return "Shares in stocks or funds."
    case .token:
      return "Token units for digital assets."
    case .gram:
      return "Weight measured in grams."
    case .ping:
      return "Area measured in ping (坪)."
    case .sqFoot:
      return "Area measured in square feet (sq ft)."
    case .sqMeter:
      return "Area measured in square meters."
    case .acre:
      return "Land area measured in acres (ac)."
    case .hectare:
      return "Land area measured in hectares (ha)."
    case .percent:
      return "Ownership percentage value."
    case .other:
      return "Use when none of the above fits."
    }
  }

  /// UI hint for default quantity precision by unit.
  public var defaultScale: Int {
    switch self {
    case .unit, .share:
      return 0
    case .token:
      return 8
    case .gram:
      return 2
    case .ping:
      return 2
    case .sqFoot:
      return 0
    case .sqMeter:
      return 1
    case .acre, .hectare:
      return 3
    case .percent:
      return 2
    case .other:
      return 0
    }
  }

  /// Built-in multipliers to convert measurement quantities between units.
  /// Formula: `valueInTarget = valueInSource * factor`.
  public static var measurementConversionMap: [AssetUnitType: [AssetUnitType: Decimal]] {
    let weightUnitBaseFactors: [AssetUnitType: Decimal] = [
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
    conversionMap.merge(buildMeasurementConversionMap(from: weightUnitBaseFactors), uniquingKeysWith: { _, new in new })
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

  /// Common real-estate area units by ISO 3166 alpha-2 code.
  public static func commonRealEstateAreaUnits(alpha2Code: String) -> [AssetUnitType] {
    let normalizedAlpha2Code = alpha2Code
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .uppercased()

    if normalizedAlpha2Code == HongKong.alpha2Code
      || normalizedAlpha2Code == Singapore.alpha2Code
      || normalizedAlpha2Code == UnitedArabEmirates.alpha2Code
    {
      return [.sqFoot, .sqMeter]
    }

    if normalizedAlpha2Code == Japan.alpha2Code
      || normalizedAlpha2Code == Taiwan.alpha2Code
    {
      return [.ping, .sqMeter]
    }

    if normalizedAlpha2Code == Canada.alpha2Code {
      return [.sqFoot, .sqMeter, .acre]
    }

    if normalizedAlpha2Code == Australia.alpha2Code {
      return [.sqMeter, .hectare, .acre]
    }

    if normalizedAlpha2Code == UnitedKingdom.alpha2Code {
      return [.sqFoot, .sqMeter, .acre, .hectare]
    }

    if normalizedAlpha2Code == UnitedStates.alpha2Code {
      return [.sqFoot, .acre]
    }

    return [.sqMeter]
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
