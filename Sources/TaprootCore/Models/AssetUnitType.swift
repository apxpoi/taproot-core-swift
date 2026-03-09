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
