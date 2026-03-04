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

    func testDecryptWithWrongPasswordThrows() throws {
        let vault = Vault(baseCurrency: "USD")
        let encrypted = try VaultCrypto.encrypt(vault: vault, password: "right-password")

        XCTAssertThrowsError(try VaultCrypto.decrypt(data: encrypted, password: "wrong-password"))
    }
}
