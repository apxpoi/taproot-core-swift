@testable import TaprootCore
import XCTest

final class VaultFileManagerTests: XCTestCase {
    func testSaveLoadExistsListAndDelete() throws {
        let fileName = uniqueFileName()
        let payload = Data("encrypted vault bytes".utf8)

        defer {
            try? VaultFileManager.delete(named: fileName)
        }

        XCTAssertFalse(try VaultFileManager.exists(named: fileName))

        try VaultFileManager.save(encryptedData: payload, named: fileName)
        XCTAssertTrue(try VaultFileManager.exists(named: fileName))

        let loaded = try VaultFileManager.load(named: fileName)
        XCTAssertEqual(loaded, payload)

        let files = try VaultFileManager.list()
        XCTAssertTrue(files.contains(fileName))

        try VaultFileManager.delete(named: fileName)
        XCTAssertFalse(try VaultFileManager.exists(named: fileName))
    }

    func testLoadMissingFileThrowsNotFound() {
        let fileName = uniqueFileName()

        XCTAssertThrowsError(try VaultFileManager.load(named: fileName)) { error in
            guard case VaultFileError.vaultNotFound = error else {
                return XCTFail("Expected vaultNotFound, got: \(error)")
            }
        }
    }

    func testDeleteMissingFileThrowsNotFound() {
        let fileName = uniqueFileName()

        XCTAssertThrowsError(try VaultFileManager.delete(named: fileName)) { error in
            guard case VaultFileError.vaultNotFound = error else {
                return XCTFail("Expected vaultNotFound, got: \(error)")
            }
        }
    }

    func testRejectsUnsafeFileNames() {
        let invalidNames = [
            "",
            "   ",
            ".",
            "..",
            "../vault",
            "vault/../other",
            #"vault\..\other"#,
        ]

        for name in invalidNames {
            XCTAssertThrowsError(try VaultFileManager.exists(named: name)) { error in
                guard case VaultFileError.invalidFileName = error else {
                    return XCTFail("Expected invalidFileName for '\(name)', got: \(error)")
                }
            }
        }
    }

    private func uniqueFileName() -> String {
        "taproot-test-\(UUID().uuidString)"
    }
}
