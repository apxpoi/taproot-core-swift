import Foundation

public protocol InstitutionProvider: Sendable {
    func institution(id: String, regionCode: String) -> Institution?
}

public protocol InstitutionRepository: InstitutionProvider, Sendable {
    func allInstitutions() -> [Institution]
}

public struct InMemoryInstitutionRepository: InstitutionRepository, Sendable {
    private let institutionsByCanonicalID: [String: Institution]

    public init(institutions: [Institution]) {
        var mapped: [String: Institution] = [:]
        for institution in institutions {
            mapped[institution.canonicalID] = institution
        }
        institutionsByCanonicalID = mapped
    }

    public func allInstitutions() -> [Institution] {
        institutionsByCanonicalID.values.sorted { lhs, rhs in
            let displayNameOrder = lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName)
            if displayNameOrder == .orderedSame {
                return lhs.canonicalID < rhs.canonicalID
            }
            return displayNameOrder == .orderedAscending
        }
    }

    public func institution(id: String, regionCode: String) -> Institution? {
        let canonicalID = Institution.canonicalID(id: id, regionCode: regionCode)
        return institutionsByCanonicalID[canonicalID]
    }
}
