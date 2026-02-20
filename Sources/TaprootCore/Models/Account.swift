import Foundation

public struct Account: Codable, Identifiable {
    public var id: UUID

    // Optional legal name parts (for personal / entity accounts)
    public var firstName: String?
    public var middleName: String?
    public var lastName: String?

    /// Required display name (e.g. "UBS Switzerland", "My Cold Wallet")
    public var displayName: String

    /// Optional type (bank, broker, crypto, vault, custom...)
    public var type: String?

    public var assets: [Asset]

    /// e.g. the unique id of "UBS", "Coinbase", "Home Safe"
    public var institution: String

    public init(
        id: UUID = UUID(),
        firstName: String? = nil,
        middleName: String? = nil,
        lastName: String? = nil,
        displayName: String,
        type: String? = nil,
        assets: [Asset] = [],
        institution: String
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
