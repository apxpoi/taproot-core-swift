@testable import TaprootCore
import XCTest

final class VaultTests: XCTestCase {
    func testEncryptDecrypt() throws {
        let wantBaseCurrency = "USD"

        let vault = Vault(baseCurrency: wantBaseCurrency)
        let password = "secret"

        let encrypted = try VaultCrypto.encrypt(vault: vault, password: password)
        let decrypted = try VaultCrypto.decrypt(data: encrypted, password: password)
        XCTAssertEqual(wantBaseCurrency, decrypted.baseCurrency)
    }
}
