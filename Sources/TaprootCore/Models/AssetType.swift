import Foundation

/// Simplified display groups for common personal finance flows.
public enum AssetTypeDisplayGroup: String, Codable, CaseIterable, Identifiable {
  case liquid = "Liquid"
  case market = "Market"
  case tangible = "Tangible"
  case other = "Other"

  public var id: String {
    return String(describing: self)
  }
}

/// Core asset taxonomy used for validation, grouping, and future extension.
public enum AssetType: String, CaseIterable, Identifiable, Hashable {
  // Liquid
  case cash
  case bankAccount

  // Market
  case securities
  case crypto

  // Tangible
  case realEstate
  case commodities
  case collectibles

  /// Catch-all
  case other

  public var id: String {
    return String(describing: self)
  }

  public var displayGroup: AssetTypeDisplayGroup {
    switch self {
    case .cash, .bankAccount:
      return .liquid
    case .securities, .crypto:
      return .market
    case .realEstate, .commodities, .collectibles:
      return .tangible
    case .other:
      return .other
    }
  }

  public var requiresValuationTimestamp: Bool {
    displayGroup == .market
  }

  public var defaultUnitType: AssetUnitType {
    switch self {
    case .cash, .bankAccount, .collectibles:
      return .unit
    case .securities:
      return .share
    case .crypto:
      return .unit
    case .realEstate:
      return .sqMeter
    case .commodities:
      return .gram
    case .other:
      return .other
    }
  }

  public var supportedUnitTypes: Set<AssetUnitType> {
    switch self {
    case .cash, .bankAccount:
      return [.unit]
    case .securities:
      return [.share, .percent, .unit]
    case .crypto:
      return [.unit]
    case .realEstate:
      return [.unit, .percent, .ping, .sqFoot, .sqMeter, .acre, .hectare]
    case .commodities:
      return [.unit, .gram]
    case .collectibles:
      return [.unit]
    case .other:
      return Set(AssetUnitType.allCases)
    }
  }

  public var supportsCustomUnitType: Bool {
    switch self {
    case .realEstate, .commodities, .collectibles, .other:
      return true
    case .cash, .bankAccount, .securities, .crypto:
      return false
    }
  }

  public func supports(unitType: AssetUnitType) -> Bool {
    supportedUnitTypes.contains(unitType)
  }

  public var displayName: String {
    switch self {
    case .cash: return "Cash"
    case .bankAccount: return "Banking"
    case .securities: return "Securities"
    case .crypto: return "Crypto"
    case .realEstate: return "Property"
    case .commodities: return "Commodities"
    case .collectibles: return "Collectibles"
    case .other: return "Other"
    }
  }

  /// Short helper text for faster asset classification in app UI.
  public var displayDescription: String {
    switch self {
    case .cash: return "Physical cash and petty cash balances."
    case .bankAccount: return "Checking, savings, money market, and wallet balances."
    case .securities: return "Stocks, ETFs, funds, bonds, and similar market instruments."
    case .crypto: return "Coins, tokens, and on-chain assets including future digital instruments."
    case .realEstate: return "Residential, commercial property, or land."
    case .commodities: return "Gold, metals, energy products, and commodity-like holdings."
    case .collectibles: return "Vehicles, art, watches, and other collectible physical items."
    case .other: return "Any asset that does not fit the predefined categories."
    }
  }
}
