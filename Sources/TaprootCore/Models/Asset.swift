import Foundation

public struct Asset: Codable, Identifiable, Hashable {
    public var id: UUID

    /// e.g. the unique id of "cash", "stock", "crypto", "gold", "real_estate"
    public var type: String

    // Total value stored as fixed-point integer
    // Example: value = 123456, currencyScale = 2 => 1234.56 USD
    public var value: Int64
    public var currency: String
    public var currencyScale: Int

    // Quantity of units
    // Example: quantity = 52310000, quantityScale = 6 => 52.31 BTC
    public var quantity: Int64
    public var quantityScale: Int

    // Unit type for measurement.
    // Example: "kg", "unit", "property", "cash"
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
    /// Returns decimal value representation (e.g. 1234.56)
    var decimalValue: Decimal {
        return Decimal(value) / FixedPointMath.pow10(currencyScale)
    }

    /// Returns decimal quantity representation (e.g. 52.31)
    var decimalQuantity: Decimal {
        return Decimal(quantity) / FixedPointMath.pow10(quantityScale)
    }
}

public enum AssetType: String, CaseIterable, Identifiable, Hashable {
    // Liquid Assets (Cash & Cash Equivalents)
    case cash = "Cash"
    case bankDeposits = "Bank Deposits (Savings)"
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

    // Digital Asset (Blockchain & Virtual)
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
