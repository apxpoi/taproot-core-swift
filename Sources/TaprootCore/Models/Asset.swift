import Foundation

public struct Asset: Codable, Identifiable, Hashable {
    public var id: UUID

    /// Logical asset category key (for example: "cash", "equities", "cryptocurrencies").
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

/// Using a two-tier structure (Group > Type)
public enum AssetType: String, CaseIterable, Identifiable, Hashable {
    // Core / High Frequency
    case bankAccount
    case cash
    case equities
    case etfsMutualFunds
    case realEstate
    case cryptocurrencies

    // Extended / Specialized
    case fixedIncome
    case derivatives
    case commodities
    case collectibles
    case vehicles
    case privateEquity
    case intellectualProperty
    case other

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .bankAccount: return "Bank & Savings"
        case .cash: return "Physical Cash"
        case .equities: return "Stocks"
        case .etfsMutualFunds: return "ETFs & Funds"
        case .realEstate: return "Property"
        case .cryptocurrencies: return "Crypto"
        case .fixedIncome: return "Bonds"
        case .derivatives: return "Options/Futures"
        case .commodities: return "Gold & Metals"
        case .collectibles: return "Collectibles"
        case .vehicles: return "Vehicles"
        case .privateEquity: return "Private Equity"
        case .intellectualProperty: return "IP & Royalties"
        case .other: return "Other"
        }
    }

    public var displayGroup: AssetTypeDisplayGroup {
        switch self {
        case .bankAccount, .cash:
            return .liquidity
        case .equities, .etfsMutualFunds, .fixedIncome, .derivatives:
            return .investments
        case .realEstate, .vehicles, .commodities, .collectibles:
            return .physical
        case .cryptocurrencies:
            return .digital
        case .privateEquity, .intellectualProperty, .other:
            return .businessAndOther
        }
    }

    /// Short helper text for non-finance users.
    public var displayDescription: String {
        switch self {
        case .bankAccount: return "Checking, savings, and digital wallets like Apple Cash, WeChat Pay or PayPal."
        case .cash: return "Physical banknotes and coins in any currency."
        case .equities: return "Shares of public companies and individual stocks."
        case .etfsMutualFunds: return "Diversified funds, index trackers, and mutual funds."
        case .realEstate: return "Residential, commercial property, or land."
        case .cryptocurrencies: return "Bitcoin, Ethereum, and other blockchain-based coins."
        case .fixedIncome: return "Government or corporate bonds and treasury bills."
        case .derivatives: return "Financial contracts like options, futures, and warrants."
        case .commodities: return "Physical assets like Gold, Silver, or Oil."
        case .collectibles: return "Art, luxury watches, jewelry, and rare items."
        case .vehicles: return "Cars, motorcycles, boats, or aircraft."
        case .privateEquity: return "Shares in private companies or startups."
        case .intellectualProperty: return "Patents, trademarks, and royalty-generating rights."
        case .other: return "Any other assets that don't fit standard categories."
        }
    }
}

public enum AssetTypeDisplayGroup: String, CaseIterable, Identifiable {
    case liquidity = "Cash & Banking"
    case investments = "Market Investments"
    case physical = "Physical Assets"
    case digital = "Digital Assets"
    case businessAndOther = "Business & Others"

    public var id: String {
        rawValue
    }
}

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
    /// Base Units
    case unit = "Unit" // Cash, Deposits
    case share = "Share" // Stocks, ETFs
    case token = "Token" // Crypto, Web3

    /// Physical & Weight
    case gram = "Gram (g)" // 1,000 of a base unit.
    case kilogram = "Kilogram (kg)"
    case troyOunce = "Troy Ounce (ozt)"
    case tael = "Tael" // For HK/Asia Gold

    // Count & Area
    case item = "Item" // Discrete physical count (for example, 3 watches).
    case contract = "Contract" // Derivatives such as options/futures.
    case squareMeter = "Sq. Meter" // Real Estate

    /// Percentages
    case ownershipPercent = "% Ownership" // Private Equity

    /// Other
    case other = "Other"

    public var id: String {
        rawValue
    }
}
