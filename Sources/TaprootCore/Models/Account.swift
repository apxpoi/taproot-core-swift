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

    /// Optional the unique id (e.g. "the_company", "hsbc").
    public var institution: String

    public init(
        id: UUID = UUID(),
        displayName: String = "Anonymous",
        assets: [Asset],
        firstName: String = "",
        middleName: String = "",
        lastName: String = "",
        type: String = "personal",
        institution: String = "default"
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
