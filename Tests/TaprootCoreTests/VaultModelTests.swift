@testable import TaprootCore
import XCTest

final class VaultModelTests: XCTestCase {
    func testInitializerDefaults() {
        let vault = Vault()

        XCTAssertEqual(vault.version, 1)
        XCTAssertEqual(vault.baseCurrency, "USD")
        XCTAssertTrue(vault.accounts.isEmpty)
    }

    func testInitializerCustomValues() {
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let account = Account(
            displayName: "Wallet",
            assets: [],
            institution: Institution(
                id: "coinbase",
                regionCode: "US",
                displayName: "Coinbase"
            )
        )
        let vault = Vault(
            version: 2,
            createdAt: createdAt,
            baseCurrency: "EUR",
            accounts: [account]
        )

        XCTAssertEqual(vault.version, 2)
        XCTAssertEqual(vault.createdAt, createdAt)
        XCTAssertEqual(vault.baseCurrency, "EUR")
        XCTAssertEqual(vault.accounts.count, 1)
        XCTAssertEqual(vault.accounts.first?.displayName, "Wallet")
    }

    func testCodableRoundTrip() throws {
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 123_400,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: "unit"
        )
        let account = Account(
            displayName: "Primary",
            assets: [asset],
            institution: Institution(
                id: "local-bank",
                regionCode: "US",
                displayName: "Local Bank"
            )
        )
        let vault = Vault(
            version: 7,
            createdAt: createdAt,
            baseCurrency: "USD",
            accounts: [account]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(vault)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Vault.self, from: data)

        XCTAssertEqual(decoded.version, 7)
        XCTAssertEqual(decoded.createdAt, createdAt)
        XCTAssertEqual(decoded.baseCurrency, "USD")
        XCTAssertEqual(decoded.accounts.count, 1)
        XCTAssertEqual(decoded.accounts.first?.displayName, "Primary")
        XCTAssertEqual(decoded.accounts.first?.institution.regionCode, "US")
        XCTAssertEqual(decoded.accounts.first?.assets.count, 1)
    }

    func testValidateAcceptsPortfolioTotalAtMaximum() throws {
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Wallet",
                    assets: [
                        Asset(type: "cash", value: 10_000_000_000_000, currency: "USD", currencyScale: 0),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertNoThrow(try vault.validate())
    }

    func testValidateRejectsPortfolioTotalAboveMaximum() {
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Wallet",
                    assets: [
                        Asset(type: "cash", value: 10_000_000_000_001, currency: "USD", currencyScale: 0),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertThrowsError(try vault.validate()) { error in
            guard case VaultValidationError.exceedsMaxTotalAssetsValue = error else {
                return XCTFail("Expected exceedsMaxTotalAssetsValue, got: \(error)")
            }
        }
    }
}
