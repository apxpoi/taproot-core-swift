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
    // Example: "Share", "Token", "Kilogram (kg)", "Currency".
    public var unitType: String

    /// Human-readable symbol for the asset (e.g. "QQQ", "AAPL").
    public var symbol: String

    public init(
        id: UUID = UUID(),
        type: String,
        value: Int64,
        currency: String,
        currencyScale: Int,
        quantity: Int64 = 1,
        quantityScale: Int = 0,
        unitType: String = "",
        symbol: String = ""
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

public enum AssetType: String, CaseIterable, Identifiable, Hashable {
    // Liquid Assets (Cash & Cash Equivalents)
    case bankDeposits = "Bank Deposits (Savings)"
    case cash = "Cash"
    case certificatesOfDeposit = "Certificates of Deposit (Time Deposit)"
    case foreignCurrency = "Foreign Currency"

    // Marketable Securities (Public Investments)
    case equities = "Equities (Stocks)"
    case fixedIncome = "Fixed Income (Bonds)"
    case etfsMutualFunds = "ETFs & Mutual Funds"
    case derivatives = "Derivatives (Options, Futures)"

    // Real Assets (Tangible/Fixed Assets)
    case realEstate = "Real Estate"
    case vehicles = "Vehicles"
    case valuablesCollectibles = "Valuables & Collectibles (Jewelry, Art)"
    case commodities = "Commodities (Gold, Silver)"

    // Digital Assets (Blockchain & Virtual)
    case cryptocurrencies = "Cryptocurrencies (BTC, ETH)"
    case stablecoins = "Stablecoins"
    case nfts = "NFTs"
    case securityTokens = "Security Tokens"

    // Private & Business Assets
    case privateEquity = "Private Equity"
    case intellectualProperty = "Intellectual Property"
    case businessEquipment = "Business Equipment"

    case other = "Other"

    public var id: String {
        rawValue
    }
}

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
    /// Liquid Assets (Cash & Cash Equivalents)
    case currency = "Currency" // Cash-like quantity in fiat units.

    // Marketable Securities (Public Investments)
    case share = "Share" // Equities, funds, and similar holdings.
    case contract = "Contract" // Derivatives such as options/futures.

    // Real Assets (Tangible/Fixed Assets)
    case kilo = "Kilo (k)" // 1,000 of a base unit.
    case kilogram = "Kilogram (kg)"
    case tael = "Tael" // Traditional bullion unit used in Hong Kong and Macau.
    case troyOunce = "Troy Ounce"
    case squareMeter = "Square Meter"
    case item = "Item" // Discrete physical count (for example, 3 watches).

    /// Digital Assets (Blockchain & Virtual)
    case token = "Token" // Crypto, security token, or NFT units.

    /// Private & Business Assets
    case ownershipPercent = "Ownership Percent" // 0-100 range with quantityScale.

    // Generic / Other
    case unit = "Unit" // Generic count when no specific unit applies.
    case other = "Other"

    public var id: String {
        rawValue
    }
}
