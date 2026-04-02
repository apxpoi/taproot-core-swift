@testable import TaprootCore
@testable import taproot_core_swift
import XCTest

final class TaprootCoreSwiftCLITests: XCTestCase {
    func testParseArgumentsWithPasswordAndOutputDirectory() throws {
        let options = try TaprootCoreSwiftCLI.parseArguments([
            "-a", "secret",
            "-d", "/tmp/out",
            "/tmp/vault.tdf",
        ])

        XCTAssertEqual(options.passwordFromArgument, "secret")
        XCTAssertEqual(options.outputDirectory, "/tmp/out")
        XCTAssertEqual(options.inputFilePath, "/tmp/vault.tdf")
    }

    func testParseArgumentsAcceptsDoubleDashSeparator() throws {
        let options = try TaprootCoreSwiftCLI.parseArguments([
            "--",
            "-a", "secret",
            "/tmp/vault.tdf",
        ])

        XCTAssertEqual(options.passwordFromArgument, "secret")
        XCTAssertEqual(options.inputFilePath, "/tmp/vault.tdf")
    }

    func testParseArgumentsRejectsUnknownOption() {
        XCTAssertThrowsError(try TaprootCoreSwiftCLI.parseArguments(["-x", "/tmp/vault.tdf"])) { error in
            guard case let CLIError.unknownOption(option) = error else {
                return XCTFail("Expected unknownOption, got: \(error)")
            }
            XCTAssertEqual(option, "-x")
        }
    }

    func testParseArgumentsRejectsMissingInputFile() {
        XCTAssertThrowsError(try TaprootCoreSwiftCLI.parseArguments(["-a", "secret"])) { error in
            guard case CLIError.missingInputFile = error else {
                return XCTFail("Expected missingInputFile, got: \(error)")
            }
        }
    }

    func testParseArgumentsRejectsInvalidExtension() {
        XCTAssertThrowsError(try TaprootCoreSwiftCLI.parseArguments(["/tmp/vault.json"])) { error in
            guard case let CLIError.invalidInputExtension(path) = error else {
                return XCTFail("Expected invalidInputExtension, got: \(error)")
            }
            XCTAssertEqual(path, "/tmp/vault.json")
        }
    }

    func testResolvePasswordFromArgument() throws {
        XCTAssertEqual(try TaprootCoreSwiftCLI.resolvePassword(passwordFromArgument: "secret"), "secret")
    }

    func testResolvePasswordRejectsEmptyArgument() {
        XCTAssertThrowsError(try TaprootCoreSwiftCLI.resolvePassword(passwordFromArgument: "")) { error in
            guard case CLIError.emptyPassword = error else {
                return XCTFail("Expected emptyPassword, got: \(error)")
            }
        }
    }

    func testDecryptVaultFileWritesJSONToSameDirectoryByDefault() throws {
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("taproot-core-cli-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)

        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let password = "demo-password"
        let vault = Vault(baseCurrency: "USD", accounts: [])
        let encrypted = try VaultCrypto.encrypt(vault: vault, password: password)

        let inputFileURL = tempDirectory.appendingPathComponent("sample.tdf")
        try encrypted.write(to: inputFileURL)

        let outputFileURL = try TaprootCoreSwiftCLI.decryptVaultFile(
            at: inputFileURL.path,
            password: password,
            outputDirectory: nil
        )

        XCTAssertEqual(outputFileURL.deletingLastPathComponent(), tempDirectory)
        XCTAssertEqual(outputFileURL.lastPathComponent, "sample.json")

        let decryptedJSON = try Data(contentsOf: outputFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedVault = try decoder.decode(Vault.self, from: decryptedJSON)

        XCTAssertEqual(decodedVault.baseCurrency, "USD")
        XCTAssertEqual(decodedVault.accounts.count, 0)
    }
}
