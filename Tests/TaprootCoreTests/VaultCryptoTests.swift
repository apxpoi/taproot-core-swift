@testable import TaprootCore
import XCTest

final class VaultCryptoTests: XCTestCase {
    func testEncryptDecryptRoundTrip() throws {
        let asset = Asset(
            id: UUID(),
            type: "cash",
            value: 15000,
            currency: "USD",
            currencyScale: 2,
            quantity: 1,
            quantityScale: 0,
            unitType: "unit"
        )
        let account = Account(
            displayName: "Main Wallet",
            assets: [asset],
            institution: Institution(
                id: "taproot",
                regionCode: "US",
                displayName: "Taproot"
            )
        )
        let vault = Vault(baseCurrency: "USD", accounts: [account])
        let password = "test-password"

        let encrypted = try VaultCrypto.encrypt(vault: vault, password: password)
        let decrypted = try VaultCrypto.decrypt(data: encrypted, password: password)

        XCTAssertEqual(decrypted.baseCurrency, "USD")
        XCTAssertEqual(decrypted.accounts.count, 1)
        XCTAssertEqual(decrypted.accounts.first?.assets.count, 1)
        XCTAssertEqual(decrypted.accounts.first?.assets.first?.value, 15000)
    }

    func testEncryptPersistsCustomKDFIterations() throws {
        let vault = Vault(baseCurrency: "USD")
        let password = "test-password"
        let customKDF = KeyDerivationParameters(
            algorithm: .pbkdf2SHA256,
            iterations: 5_000
        )

        let encrypted = try VaultCrypto.encrypt(
            vault: vault,
            password: password,
            keyDerivation: customKDF
        )

        let parsed = try VaultContainer.parseWithMetadata(data: encrypted)
        XCTAssertEqual(parsed.formatVersion, 1)
        XCTAssertEqual(parsed.keyDerivation, customKDF)

        let decrypted = try VaultCrypto.decrypt(data: encrypted, password: password)
        XCTAssertEqual(decrypted.baseCurrency, "USD")
    }

    func testDecryptWithWrongPasswordThrows() throws {
        let vault = Vault(baseCurrency: "USD")
        let encrypted = try VaultCrypto.encrypt(vault: vault, password: "right-password")

        XCTAssertThrowsError(try VaultCrypto.decrypt(data: encrypted, password: "wrong-password"))
    }

    func testEncryptDecryptSupportsMixedCurrencyVault() throws {
        let usdAsset = Asset(
            type: "cash",
            value: 10_000_000_000_001,
            currency: "USD",
            currencyScale: 0
        )
        let eurAsset = Asset(
            type: "cash",
            value: 9_999_999_999_999,
            currency: "EUR",
            currencyScale: 0
        )
        let account = Account(
            displayName: "Main Wallet",
            assets: [usdAsset, eurAsset],
            institution: Institution(id: "taproot", regionCode: "US", displayName: "Taproot")
        )
        let vault = Vault(baseCurrency: "USD", accounts: [account])

        let encrypted = try VaultCrypto.encrypt(vault: vault, password: "test-password")
        let decrypted = try VaultCrypto.decrypt(data: encrypted, password: "test-password")

        XCTAssertEqual(decrypted.accounts.first?.assets.count, 2)
        XCTAssertEqual(decrypted.accounts.first?.assets.first?.currency, "USD")
        XCTAssertEqual(decrypted.accounts.first?.assets.last?.currency, "EUR")
    }
}
