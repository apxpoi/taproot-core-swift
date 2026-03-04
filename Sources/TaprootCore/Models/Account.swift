import Foundation

public struct Account: Codable, Identifiable, Hashable {
    public var id: UUID

    // Optional legal name parts (for personal / entity accounts).
    public var firstName: String
    public var middleName: String
    public var lastName: String

    /// Required display name (e.g. "Mr. & Mrs. Smith's Wallet", "Taproot LLC").
    public var displayName: String

    /// Optional type (e.g. "personal", "joint", "legal_entity", "trusts").
    public var type: String

    public var assets: [Asset]

    /// Institution metadata for this account (for example: id "hsbc", region "HK").
    public var institution: Institution

    public init(
        id: UUID = UUID(),
        displayName: String = "Anonymous",
        assets: [Asset],
        firstName: String = "",
        middleName: String = "",
        lastName: String = "",
        type: String = "personal",
        institution: Institution = .default
    ) {
        self.id = id

        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName

        self.displayName = displayName

        self.type = type

        self.assets = assets

        self.institution = institution
    }
}

public extension Account {
    /// Returns provider-enriched institution metadata when available.
    func resolvedInstitution(from provider: InstitutionProvider) -> Institution {
        provider.institution(id: institution.id, regionCode: institution.regionCode) ?? institution
    }
}
