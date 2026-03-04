import Foundation

public struct Institution: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var regionCode: String
    public var displayName: String
    public var description: String?
    public var category: InstitutionCategory?

    public static let `default` = Institution(
        id: "default",
        regionCode: "ZZ",
        displayName: "Default Institution"
    )

    public init(
        id: String,
        regionCode: String,
        displayName: String,
        description: String? = nil,
        category: InstitutionCategory? = nil
    ) {
        let trimmedID = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.id = trimmedID.isEmpty ? Institution.default.id : trimmedID

        let trimmedRegionCode = regionCode.trimmingCharacters(in: .whitespacesAndNewlines)
        self.regionCode = trimmedRegionCode.isEmpty ? Institution.default.regionCode : trimmedRegionCode.uppercased()

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.displayName = trimmedDisplayName.isEmpty ? self.id : trimmedDisplayName

        let trimmedDescription = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = (trimmedDescription?.isEmpty == true) ? nil : trimmedDescription

        self.category = category
    }

    /// Stable, case-insensitive key used for map indexing and offline lookups.
    public var canonicalID: String {
        Self.canonicalID(id: id, regionCode: regionCode)
    }

    public static func canonicalID(id: String, regionCode: String) -> String {
        let normalizedID = id.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedRegion = regionCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return "\(normalizedRegion)::\(normalizedID)"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case regionCode
        case displayName
        case description
        case category
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let rawID = try keyedContainer.decode(String.self, forKey: .id)
        let rawRegionCode = try keyedContainer.decode(String.self, forKey: .regionCode)
        let rawDisplayName = try keyedContainer.decode(String.self, forKey: .displayName)
        let rawDescription = try keyedContainer.decodeIfPresent(String.self, forKey: .description)
        let rawCategory = try keyedContainer.decodeIfPresent(InstitutionCategory.self, forKey: .category)

        self.init(
            id: rawID,
            regionCode: rawRegionCode,
            displayName: rawDisplayName,
            description: rawDescription,
            category: rawCategory
        )
    }

    public func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
        try keyedContainer.encode(id, forKey: .id)
        try keyedContainer.encode(regionCode, forKey: .regionCode)
        try keyedContainer.encode(displayName, forKey: .displayName)
        try keyedContainer.encodeIfPresent(description, forKey: .description)
        try keyedContainer.encodeIfPresent(category, forKey: .category)
    }
}

public enum InstitutionCategory: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case bank
    case brokerage
    case cryptoExchange
    case paymentProvider
    case wallet
    case other

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .bank:
            return "Bank"
        case .brokerage:
            return "Brokerage"
        case .cryptoExchange:
            return "Crypto Exchange"
        case .paymentProvider:
            return "Payment Provider"
        case .wallet:
            return "Wallet"
        case .other:
            return "Other"
        }
    }

    /// Short helper text for non-finance users selecting an institution category.
    public var displayDescription: String {
        switch self {
        case .bank:
            return "Licensed banks and regulated deposit institutions (e.g. HSBC, BOA)."
        case .brokerage:
            return "Investment brokers and securities custody platforms (e.g. Fidelity, Interactive Brokers)."
        case .cryptoExchange:
            return "Centralized crypto exchanges that enable trading and custody (e.g. Coinbase, Kraken)."
        case .paymentProvider:
            return "Digital payment and transfer platforms (e.g. Apple Pay, Wise, PayPal)."
        case .wallet:
            return "Wallet-focused products for storing funds or tokens (e.g. Ledger Live, MetaMask)."
        case .other:
            return "Use when the institution does not fit banking, brokerage, exchange, payment provider, or wallet."
        }
    }
}
