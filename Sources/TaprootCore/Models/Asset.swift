import Foundation

public struct Asset: Codable, Identifiable, Hashable {
    public var id: UUID

    /// Logical asset category key (for example: "cash", "securities", "crypto").
    public var type: String

    // Total value stored as a fixed-point integer.
    // Example: value = 123456, currencyScale = 2 => 1234.56 USD.
    public var value: Int64
    public var currency: String
    public var currencyScale: Int

    // Quantity stored as a fixed-point integer.
    // Example: quantity = 52310000, quantityScale = 6 => 52.31.
    public var quantity: Int64
    public var quantityScale: Int

    // Unit label for quantity measurement.
    // Example: "Share", "Token", "Kilogram (kg)", "Unit".
    public var unitType: String

    /// Human-readable symbol for the asset (e.g. "QQQ", "AAPL").
    public var symbol: String

    public var note: String

    public init(
        id: UUID = UUID(),
        type: String,
        value: Int64,
        currency: String,
        currencyScale: Int,
        quantity: Int64 = 1,
        quantityScale: Int = 0,
        unitType: String = "",
        symbol: String = "",
        note: String = ""
    ) {
        self.id = id

        self.type = type

        self.value = value
        self.currency = currency
        self.currencyScale = currencyScale

        self.quantity = quantity
        self.quantityScale = quantityScale

        self.unitType = unitType

        self.symbol = symbol

        self.note = note
    }
}

public extension Asset {
    /// Returns the decimal value derived from `value` and `currencyScale` (for example, 1234.56).
    var decimalValue: Decimal {
        return Decimal(value) / FixedPointMath.pow10(currencyScale)
    }

    /// Returns the decimal quantity derived from `quantity` and `quantityScale` (for example, 52.31).
    var decimalQuantity: Decimal {
        return Decimal(quantity) / FixedPointMath.pow10(quantityScale)
    }
}

/// Simplified display groups for common personal finance flows.
public enum AssetTypeDisplayGroup: String, CaseIterable, Identifiable {
    case liquid = "Liquid"
    case market = "Market"
    case tangible = "Tangible"

    public var id: String { rawValue }
}

/// Core asset taxonomy optimized for app UX and future extension.
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

    // Catch-all
    case other

    public var id: String { rawValue }

    public var displayGroup: AssetTypeDisplayGroup {
        switch self {
        case .cash, .bankAccount:
            return .liquid
        case .securities, .crypto:
            return .market
        case .realEstate, .commodities, .collectibles, .other:
            return .tangible
        }
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

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
    // Core counting
    case unit = "Unit"
    case share = "Share"
    case token = "Token"

    // Measurements
    case gram = "Gram (g)"
    case sqMeter = "Sq. Meter"

    // Special
    case percent = "%"
    case other = "Other"

    public var id: String { rawValue }

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
