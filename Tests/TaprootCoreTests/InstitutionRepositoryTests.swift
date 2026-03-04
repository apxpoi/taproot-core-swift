@testable import TaprootCore
import XCTest

final class InstitutionRepositoryTests: XCTestCase {
    func testFindByIDAndRegionUsesCanonicalLookup() {
        let repository = InMemoryInstitutionRepository(
            institutions: [
                Institution(id: "hsbc", regionCode: "HK", displayName: "HSBC Hong Kong"),
                Institution(id: "hsbc", regionCode: "GB", displayName: "HSBC UK"),
            ]
        )

        let hkInstitution = repository.institution(id: "HSBC", regionCode: "hk")
        XCTAssertEqual(hkInstitution?.displayName, "HSBC Hong Kong")
    }

    func testAllInstitutionsReturnsSortedDisplayNames() {
        let repository = InMemoryInstitutionRepository(
            institutions: [
                Institution(id: "zeta", regionCode: "US", displayName: "Zeta Bank"),
                Institution(id: "alpha", regionCode: "US", displayName: "Alpha Brokerage"),
            ]
        )

        let names = repository.allInstitutions().map(\.displayName)
        XCTAssertEqual(names, ["Alpha Brokerage", "Zeta Bank"])
    }
}
