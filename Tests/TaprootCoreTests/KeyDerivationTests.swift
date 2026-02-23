@testable import TaprootCore
import Crypto
import XCTest

final class KeyDerivationTests: XCTestCase {
  func testMatchesPBKDF2SHA256KnownVectorIteration1() throws {
    let key = try KeyDerivation.deriveKey(
      password: "password",
      salt: Data("salt".utf8),
      iterations: 1
    )

    XCTAssertEqual(
      hexString(keyData(key)),
      "120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b"
    )
  }

  func testMatchesPBKDF2SHA256KnownVectorIteration2() throws {
    let key = try KeyDerivation.deriveKey(
      password: "password",
      salt: Data("salt".utf8),
      iterations: 2
    )

    XCTAssertEqual(
      hexString(keyData(key)),
      "ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43"
    )
  }

  func testMatchesPBKDF2SHA256KnownVectorIteration4096() throws {
    let key = try KeyDerivation.deriveKey(
      password: "password",
      salt: Data("salt".utf8),
      iterations: 4_096
    )

    XCTAssertEqual(
      hexString(keyData(key)),
      "c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a"
    )
  }

  func testMatchesKnownVectorForEmptyPasswordAndSalt() throws {
    let key = try KeyDerivation.deriveKey(
      password: "",
      salt: Data(),
      iterations: 1
    )

    XCTAssertEqual(
      hexString(keyData(key)),
      "f7ce0b653d2d72a4108cf5abe912ffdd777616dbbb27a70e8204f3ae2d0f6fad"
    )
  }

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

  private func hexString(_ data: Data) -> String {
    data.map { String(format: "%02x", $0) }.joined()
  }
}
