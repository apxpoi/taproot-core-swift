@testable import TaprootCore
import XCTest

final class VaultContainerTests: XCTestCase {
    func testBuildAndParseRoundTrip() throws {
        let salt = Data(repeating: 0x11, count: 16)
        let ciphertext = Data([0xAA, 0xBB, 0xCC, 0xDD])
        let data = VaultContainer.build(salt: salt, ciphertext: ciphertext)

        let parsed = try VaultContainer.parse(data: data)
        XCTAssertEqual(parsed.salt, salt)
        XCTAssertEqual(parsed.ciphertext, ciphertext)
    }

    func testRejectsTooShortData() {
        let shortData = Data(repeating: 0x00, count: 10)

        XCTAssertThrowsError(try VaultContainer.parse(data: shortData)) { error in
            guard case VaultContainerError.invalidFile = error else {
                return XCTFail("Expected invalidFile, got: \(error)")
            }
        }
    }

    func testRejectsInvalidMagicHeader() {
        var data = Data("INVALID!".utf8) // 8 bytes, same length as TAPROOT1
        data.append(Data(repeating: 0x00, count: 16))
        data.append(0x01)

        XCTAssertThrowsError(try VaultContainer.parse(data: data)) { error in
            guard case VaultContainerError.invalidMagicHeader = error else {
                return XCTFail("Expected invalidMagicHeader, got: \(error)")
            }
        }
    }
}
