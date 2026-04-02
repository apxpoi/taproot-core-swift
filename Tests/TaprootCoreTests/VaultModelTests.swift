@testable import TaprootCore
import XCTest

final class VaultModelTests: XCTestCase {
    func testInitializerDefaults() {
        let vault = Vault()

        XCTAssertEqual(vault.version, 1)
        XCTAssertEqual(vault.baseCurrency, "USD")
        XCTAssertTrue(vault.accounts.isEmpty)
        XCTAssertTrue(vault.snapshots.isEmpty)
        XCTAssertTrue(vault.cashFlows.isEmpty)
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
        XCTAssertTrue(decoded.snapshots.isEmpty)
        XCTAssertTrue(decoded.cashFlows.isEmpty)
    }

    func testValidatePortfolioTotalAcceptsMaximum() throws {
        let vault = Vault(baseCurrency: "USD")
        XCTAssertNoThrow(
            try vault.validatePortfolioTotal(baseCurrencyTotal: TaprootLimitsV1.maxTotalAssetsValue)
        )
    }

    func testValidatePortfolioTotalRejectsAboveMaximum() {
        let vault = Vault(baseCurrency: "USD")

        XCTAssertThrowsError(
            try vault.validatePortfolioTotal(baseCurrencyTotal: TaprootLimitsV1.maxTotalAssetsValue + 1)
        ) { error in
            guard case VaultValidationError.exceedsMaxTotalAssetsValue = error else {
                return XCTFail("Expected exceedsMaxTotalAssetsValue, got: \(error)")
            }
        }
    }

    func testValidateAcceptsMixedCurrencyVaultStructure() throws {
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Wallet",
                    assets: [
                        Asset(type: "cash", value: 10_000_000_000_001, currency: "USD", currencyScale: 0),
                        Asset(type: "cash", value: 9_999_999_999_999, currency: "EUR", currencyScale: 0),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertNoThrow(try vault.validate())
    }

    func testValidateRejectsInvalidInstitutionStructure() {
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    displayName: "Wallet",
                    assets: [
                        Asset(type: "cash", value: 100, currency: "USD", currencyScale: 0),
                    ],
                    institution: Institution(id: "taproot", regionCode: "USA", displayName: "Taproot")
                ),
            ]
        )

        XCTAssertThrowsError(try vault.validate()) { error in
            guard case InstitutionValidationError.invalidRegionCode = error else {
                return XCTFail("Expected invalidRegionCode, got: \(error)")
            }
        }
    }

    func testValidateAcceptsSnapshotsAndCashFlows() throws {
        let accountID = UUID()
        let vault = Vault(
            baseCurrency: "USD",
            accounts: [
                Account(
                    id: accountID,
                    displayName: "Brokerage",
                    assets: [
                        Asset(
                            type: AssetType.securities.id,
                            value: 100_000,
                            currency: "USD",
                            currencyScale: 2,
                            quantity: 100,
                            quantityScale: 0,
                            unitType: AssetUnitType.share.id,
                            symbol: "TAP",
                            valuationAtUnixMs: 1_772_064_000_000
                        ),
                    ],
                    institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
                ),
            ],
            snapshots: [
                PortfolioSnapshot(
                    capturedAtUnixMs: 1_772_064_000_000,
                    baseCurrency: "USD",
                    totalValue: 100_000,
                    totalValueScale: 2,
                    groupValues: [
                        PortfolioSnapshotGroupValue(group: .market, value: 100_000),
                    ]
                ),
            ],
            cashFlows: [
                CashFlowEvent(
                    occurredAtUnixMs: 1_772_000_000_000,
                    type: .contribution,
                    amount: 100_000,
                    currency: "USD",
                    currencyScale: 2,
                    accountID: accountID
                ),
            ]
        )

        XCTAssertNoThrow(try vault.validate())
    }

    func testValidateRejectsSnapshotBaseCurrencyMismatch() {
        let vault = Vault(
            baseCurrency: "USD",
            snapshots: [
                PortfolioSnapshot(
                    capturedAtUnixMs: 1_772_064_000_000,
                    baseCurrency: "EUR",
                    totalValue: 0,
                    totalValueScale: 2
                ),
            ]
        )

        XCTAssertThrowsError(try vault.validate()) { error in
            guard case VaultValidationError.snapshotBaseCurrencyMismatch = error else {
                return XCTFail("Expected snapshotBaseCurrencyMismatch, got: \(error)")
            }
        }
    }

    func testValidateRejectsUnsortedSnapshots() {
        let vault = Vault(
            baseCurrency: "USD",
            snapshots: [
                PortfolioSnapshot(
                    capturedAtUnixMs: 2_000,
                    baseCurrency: "USD",
                    totalValue: 0,
                    totalValueScale: 2
                ),
                PortfolioSnapshot(
                    capturedAtUnixMs: 1_000,
                    baseCurrency: "USD",
                    totalValue: 0,
                    totalValueScale: 2
                ),
            ]
        )

        XCTAssertThrowsError(try vault.validate()) { error in
            guard case VaultValidationError.snapshotsMustBeSortedByTimestamp = error else {
                return XCTFail("Expected snapshotsMustBeSortedByTimestamp, got: \(error)")
            }
        }
    }

    func testValidateRejectsCashFlowWithUnknownAccountReference() {
        let vault = Vault(
            baseCurrency: "USD",
            cashFlows: [
                CashFlowEvent(
                    occurredAtUnixMs: 1_772_000_000_000,
                    type: .contribution,
                    amount: 100_000,
                    currency: "USD",
                    currencyScale: 2,
                    accountID: UUID()
                ),
            ]
        )

        XCTAssertThrowsError(try vault.validate()) { error in
            guard case VaultValidationError.cashFlowReferencesUnknownAccount = error else {
                return XCTFail("Expected cashFlowReferencesUnknownAccount, got: \(error)")
            }
        }
    }
}
