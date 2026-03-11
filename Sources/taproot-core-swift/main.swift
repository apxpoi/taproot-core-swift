import Foundation
import TaprootCore
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

struct CLIOptions {
    let passwordFromArgument: String?
    let outputDirectory: String?
    let inputFilePath: String
}

enum CLIError: Error, CustomStringConvertible {
    case helpRequested
    case missingOptionValue(option: String)
    case unknownOption(String)
    case missingInputFile
    case multipleInputFiles([String])
    case invalidInputExtension(String)
    case emptyPassword
    case missingPassword

    var description: String {
        switch self {
        case .helpRequested:
            return ""
        case let .missingOptionValue(option):
            return "Missing value for option: \(option)"
        case let .unknownOption(option):
            return "Unknown option: \(option)"
        case .missingInputFile:
            return "Missing required <path/to/.tdfFile> argument."
        case let .multipleInputFiles(paths):
            return "Only one .tdf input file is supported. Received: \(paths.joined(separator: ", "))"
        case let .invalidInputExtension(path):
            return "Input file must use .tdf extension: \(path)"
        case .emptyPassword:
            return "Password cannot be empty."
        case .missingPassword:
            return "Password is required. Use -a <password> or provide it via stdin when prompted."
        }
    }
}

@main
struct TaprootCoreSwiftCLI {
    static func main() {
        do {
            let options = try parseArguments(Array(CommandLine.arguments.dropFirst()))
            if options.passwordFromArgument != nil {
                fputs("Warning: Using a password with '-a' option on the command line interface may not be safe.\n", stderr)
            }

            let password = try resolvePassword(passwordFromArgument: options.passwordFromArgument)
            let outputURL = try decryptVaultFile(at: options.inputFilePath, password: password, outputDirectory: options.outputDirectory)

            print("Decrypted vault written to: \(outputURL.path)")
        } catch CLIError.helpRequested {
            print(usageText)
            exit(EXIT_SUCCESS)
        } catch let error as CLIError {
            if !error.description.isEmpty {
                fputs("Error: \(error.description)\n\n", stderr)
            }
            fputs("\(usageText)\n", stderr)
            exit(EXIT_FAILURE)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(EXIT_FAILURE)
        }
    }

    static func parseArguments(_ args: [String]) throws -> CLIOptions {
        var passwordFromArgument: String?
        var outputDirectory: String?
        var positionalArguments: [String] = []

        var index = 0
        while index < args.count {
            let arg = args[index]

            switch arg {
            case "-h", "--help":
                throw CLIError.helpRequested

            case "--":
                index += 1

            case "-a":
                let valueIndex = index + 1
                guard valueIndex < args.count else {
                    throw CLIError.missingOptionValue(option: "-a")
                }
                passwordFromArgument = args[valueIndex]
                index += 2

            case "-d":
                let valueIndex = index + 1
                guard valueIndex < args.count else {
                    throw CLIError.missingOptionValue(option: "-d")
                }
                outputDirectory = args[valueIndex]
                index += 2

            default:
                if arg.hasPrefix("-") {
                    throw CLIError.unknownOption(arg)
                }
                positionalArguments.append(arg)
                index += 1
            }
        }

        guard !positionalArguments.isEmpty else {
            throw CLIError.missingInputFile
        }
        guard positionalArguments.count == 1 else {
            throw CLIError.multipleInputFiles(positionalArguments)
        }

        let inputFilePath = positionalArguments[0]
        guard URL(fileURLWithPath: inputFilePath).pathExtension.lowercased() == "tdf" else {
            throw CLIError.invalidInputExtension(inputFilePath)
        }

        return CLIOptions(
            passwordFromArgument: passwordFromArgument,
            outputDirectory: outputDirectory,
            inputFilePath: inputFilePath
        )
    }

    static func resolvePassword(passwordFromArgument: String?) throws -> String {
        if let passwordFromArgument {
            guard !passwordFromArgument.isEmpty else {
                throw CLIError.emptyPassword
            }
            return passwordFromArgument
        }

        if isatty(fileno(stdin)) != 0 {
            fputs("Password: ", stdout)
            fflush(stdout)
        }

        guard let line = readLine(strippingNewline: true) else {
            throw CLIError.missingPassword
        }
        guard !line.isEmpty else {
            throw CLIError.emptyPassword
        }

        return line
    }

    static func decryptVaultFile(at inputFilePath: String, password: String, outputDirectory: String?) throws -> URL {
        let inputFileURL = URL(fileURLWithPath: inputFilePath)
        let encryptedData = try Data(contentsOf: inputFileURL)
        let vault = try VaultCrypto.decrypt(data: encryptedData, password: password)

        let outputDirectoryURL: URL
        if let outputDirectory {
            outputDirectoryURL = URL(fileURLWithPath: outputDirectory, isDirectory: true)
        } else {
            outputDirectoryURL = inputFileURL.deletingLastPathComponent()
        }

        try FileManager.default.createDirectory(
            at: outputDirectoryURL,
            withIntermediateDirectories: true
        )

        let outputFileName = "\(inputFileURL.deletingPathExtension().lastPathComponent).json"
        let outputFileURL = outputDirectoryURL.appendingPathComponent(outputFileName, isDirectory: false)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let outputData = try encoder.encode(vault)

        try outputData.write(to: outputFileURL, options: .atomic)
        try? FileManager.default.setAttributes(
            [.posixPermissions: 0o600],
            ofItemAtPath: outputFileURL.path
        )

        return outputFileURL
    }

    static let usageText = """
    Usage:
      taproot-core-swift [-a <password>] [-d <outputFolder>] <path/to/.tdfFile>

    Options:
      -a <password>  Password used for decryption.
      -d <folder>    Output folder for decrypted JSON.
                    Default: same folder as the .tdf file.
      -h, --help     Show this help.
    """
}
