@testable import TaprootCore
import CryptoKit
import XCTest

final class KeyDerivationTests: XCTestCase {
  func testProduces32ByteKey() throws {
    let salt = Data("0123456789abcdef".utf8)
    let key = try KeyDerivation.deriveKey(
      password: "correct horse battery staple",
      salt: salt,
      iterations: 1_000
    )

    XCTAssertEqual(keyData(key).count, 32)
  }

  func testIsDeterministicForSameInput() throws {
    let salt = Data("fixed-salt-value".utf8)
    let password = "p@ssw0rd"

    let key1 = try KeyDerivation.deriveKey(password: password, salt: salt, iterations: 1_000)
    let key2 = try KeyDerivation.deriveKey(password: password, salt: salt, iterations: 1_000)

    XCTAssertEqual(keyData(key1), keyData(key2))
  }

  func testRejectsNonPositiveIterations() {
    XCTAssertThrowsError(
      try KeyDerivation.deriveKey(password: "secret", salt: Data([0x00]), iterations: 0)
    ) { error in
      guard case KeyDerivationError.invalidIterationCount = error else {
        return XCTFail("Expected invalidIterationCount, got: \(error)")
      }
    }
  }

  private func keyData(_ key: SymmetricKey) -> Data {
    key.withUnsafeBytes { Data($0) }
  }
}
