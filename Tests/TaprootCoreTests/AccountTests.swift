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
            institution: "Fidelity"
        )

        XCTAssertEqual(account.id, accountID)
        XCTAssertEqual(account.firstName, "Ada")
        XCTAssertEqual(account.middleName, "M")
        XCTAssertEqual(account.lastName, "Lovelace")
        XCTAssertEqual(account.displayName, "Brokerage")
        XCTAssertEqual(account.type, "broker")
        XCTAssertEqual(account.assets.count, 1)
        XCTAssertEqual(account.assets.first?.id, assetID)
        XCTAssertEqual(account.institution, "Fidelity")
    }
}
