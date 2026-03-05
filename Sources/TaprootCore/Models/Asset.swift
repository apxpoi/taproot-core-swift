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

public enum AssetType: String, CaseIterable, Identifiable, Hashable {
    // Liquid Assets (Cash & Cash Equivalents)
    case bankDeposits
    case digitalWallet
    case cash
    case certificatesOfDeposit
    case foreignCurrency

    // Marketable Securities (Public Investments)
    case equities
    case fixedIncome
    case etfsMutualFunds
    case derivatives

    // Real Assets (Tangible/Fixed Assets)
    case realEstate
    case vehicles
    case valuablesCollectibles
    case commodities

    // Digital Assets (Blockchain & Virtual)
    case cryptocurrencies
    case stablecoins
    case nfts
    case securityTokens

    // Private & Business Assets
    case privateEquity
    case intellectualProperty
    case businessEquipment

    case other

    public var id: String {
        rawValue
    }

    /// User-friendly label suitable for app pickers and list views.
    public var displayName: String {
        switch self {
        case .bankDeposits:
            return "Bank Accounts"
        case .digitalWallet:
            return "Digital Wallet"
        case .cash:
            return "Cash"
        case .certificatesOfDeposit:
            return "Fixed Deposits"
        case .foreignCurrency:
            return "Foreign Cash"
        case .equities:
            return "Stocks"
        case .fixedIncome:
            return "Bonds"
        case .etfsMutualFunds:
            return "ETFs & Funds"
        case .derivatives:
            return "Options & Futures"
        case .realEstate:
            return "Property"
        case .vehicles:
            return "Vehicles"
        case .valuablesCollectibles:
            return "Collectibles"
        case .commodities:
            return "Gold & Commodities"
        case .cryptocurrencies:
            return "Crypto"
        case .stablecoins:
            return "Stablecoins"
        case .nfts:
            return "NFT Collectibles"
        case .securityTokens:
            return "Tokenized Securities"
        case .privateEquity:
            return "Private Shares"
        case .intellectualProperty:
            return "Patents & Royalties"
        case .businessEquipment:
            return "Business Equipment"
        case .other:
            return "Other"
        }
    }

    /// Short helper text for non-finance users.
    public var displayDescription: String {
        switch self {
        case .bankDeposits:
            return "Savings and checking account balances."
        case .digitalWallet:
            return "Apple Cash, PayPal and Telegram Wallet."
        case .cash:
            return "Physical cash you currently hold."
        case .certificatesOfDeposit:
            return "Fixed-term bank deposits."
        case .foreignCurrency:
            return "Cash balances in other currencies."
        case .equities:
            return "Public company shares."
        case .fixedIncome:
            return "Bonds and other interest-paying debt."
        case .etfsMutualFunds:
            return "Diversified pooled investment funds."
        case .derivatives:
            return "Contracts linked to an underlying asset."
        case .realEstate:
            return "Homes, land, and other real property."
        case .vehicles:
            return "Cars, boats, and transport assets."
        case .valuablesCollectibles:
            return "Jewelry, art, watches, and similar items."
        case .commodities:
            return "Gold, silver, oil, and raw materials."
        case .cryptocurrencies:
            return "Blockchain coins and tokens."
        case .stablecoins:
            return "Crypto assets pegged to fiat value."
        case .nfts:
            return "Unique blockchain collectibles."
        case .securityTokens:
            return "Regulated tokenized ownership assets."
        case .privateEquity:
            return "Ownership in private companies."
        case .intellectualProperty:
            return "Patents, trademarks, and royalty rights."
        case .businessEquipment:
            return "Machinery, tools, and office equipment."
        case .other:
            return "Use when no category fits."
        }
    }

    /// Broad section used to organize app category pickers.
    public var displayGroup: AssetTypeDisplayGroup {
        switch self {
        case .bankDeposits, .digitalWallet, .cash, .certificatesOfDeposit, .foreignCurrency:
            return .cashAndBanking
        case .equities, .fixedIncome, .etfsMutualFunds, .derivatives:
            return .investments
        case .realEstate, .vehicles, .valuablesCollectibles, .commodities:
            return .physicalAssets
        case .cryptocurrencies, .stablecoins, .nfts, .securityTokens:
            return .digitalAssets
        case .privateEquity, .intellectualProperty, .businessEquipment:
            return .privateBusiness
        case .other:
            return .other
        }
    }
}

public enum AssetTypeDisplayGroup: String, CaseIterable, Identifiable, Hashable {
    case cashAndBanking = "Cash & Banking"
    case investments = "Investments"
    case physicalAssets = "Property & Physical"
    case digitalAssets = "Digital Assets"
    case privateBusiness = "Private & Business"
    case other = "Other"

    public var id: String {
        rawValue
    }
}

public enum AssetUnitType: String, Codable, CaseIterable, Identifiable, Hashable {
    /// Liquid Assets (Cash & Cash Equivalents)
    case unit = "Unit" // Cash-like quantity in fiat units.

    // Marketable Securities (Public Investments)
    case share = "Share" // Equities, funds, and similar holdings.
    case contract = "Contract" // Derivatives such as options/futures.

    // Real Assets (Tangible/Fixed Assets)
    case gram = "Gram (g)" // 1,000 of a base unit.
    case kilogram = "Kilogram (kg)"
    case tael = "Tael" // Traditional bullion unit used in Hong Kong and Macau.
    case troyOunce = "Troy Ounce (ozt)"
    case squareMeter = "Square Meter"
    case item = "Item" // Discrete physical count (for example, 3 watches).

    /// Digital Assets (Blockchain & Virtual)
    case token = "Token" // Crypto, security token, or NFT units.

    /// Private & Business Assets
    case ownershipPercent = "Ownership Percent" // 0-100 range with quantityScale.

    /// Other
    case other = "Other"

    public var id: String {
        rawValue
    }
}
