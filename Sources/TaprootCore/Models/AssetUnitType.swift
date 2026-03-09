import Foundation

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
  // Core counting
  case unit = "Unit"
  case share = "Share"
  case token = "Token"

  // Measurements
  case gram = "Gram (g)"
  case sqMeter = "Sq. Meter"

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
    case .gram, .sqMeter:
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
    case .sqMeter:
      return "Area measured in square meters."
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
    case .sqMeter:
      return 1
    case .percent:
      return 2
    case .other:
      return 0
    }
  }
}
