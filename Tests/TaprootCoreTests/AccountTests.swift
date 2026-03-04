@testable import TaprootCore
import XCTest

final class AccountTests: XCTestCase {
    func testInitializerAssignsAllProperties() {
        let accountID = UUID()
        let assetID = UUID()
        let asset = Asset(
            id: assetID,
            type: "stock",
            value: 25000,
            currency: "USD",
            currencyScale: 2,
            quantity: 10,
            quantityScale: 0,
            unitType: "share"
        )

        let account = Account(
            id: accountID,
            displayName: "Brokerage",
            assets: [asset],
            firstName: "Ada",
            middleName: "M",
            lastName: "Lovelace",
            type: "broker",
            institution: Institution(
                id: "fidelity",
                regionCode: "US",
                displayName: "Fidelity"
            )
        )

        XCTAssertEqual(account.id, accountID)
        XCTAssertEqual(account.firstName, "Ada")
        XCTAssertEqual(account.middleName, "M")
        XCTAssertEqual(account.lastName, "Lovelace")
        XCTAssertEqual(account.displayName, "Brokerage")
        XCTAssertEqual(account.type, "broker")
        XCTAssertEqual(account.assets.count, 1)
        XCTAssertEqual(account.assets.first?.id, assetID)
        XCTAssertEqual(account.institution.id, "fidelity")
    }

    func testDecodesInstitutionObject() throws {
        let data = Data(
            """
            {
              "id": "123E4567-E89B-12D3-A456-426614174000",
              "firstName": "",
              "middleName": "",
              "lastName": "",
              "displayName": "Brokerage",
              "type": "personal",
              "assets": [],
              "institution": {
                "id": "structured-bank",
                "regionCode": "US",
                "displayName": "Structured Bank"
              }
            }
            """.utf8
        )

        let decoder = JSONDecoder()
        let account = try decoder.decode(Account.self, from: data)

        XCTAssertEqual(account.institution.id, "structured-bank")
        XCTAssertEqual(account.institution.regionCode, "US")
        XCTAssertEqual(account.institution.displayName, "Structured Bank")
    }

    func testResolvedInstitutionReturnsProviderValueWhenFound() {
        let account = Account(
            displayName: "Wallet",
            assets: [],
            institution: Institution(
                id: "wise",
                regionCode: "SG",
                displayName: "Wise (Local)"
            )
        )

        let provider = InMemoryInstitutionRepository(
            institutions: [
                Institution(
                    id: "wise",
                    regionCode: "SG",
                    displayName: "Wise",
                    description: "Global payments and remittance",
                    category: .paymentProvider
                ),
            ]
        )

        let resolved = account.resolvedInstitution(from: provider)

        XCTAssertEqual(resolved.displayName, "Wise")
        XCTAssertEqual(resolved.category, .paymentProvider)
    }

    func testResolvedInstitutionFallsBackToStoredValueWhenMissing() {
        let accountInstitution = Institution(
            id: "local-bank",
            regionCode: "US",
            displayName: "Local Bank"
        )
        let account = Account(
            displayName: "Wallet",
            assets: [],
            institution: accountInstitution
        )

        let provider = InMemoryInstitutionRepository(institutions: [])
        let resolved = account.resolvedInstitution(from: provider)

        XCTAssertEqual(resolved, accountInstitution)
    }
}
