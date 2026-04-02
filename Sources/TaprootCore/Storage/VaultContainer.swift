import Foundation

public enum VaultContainer {
    static let magic = "TAPROOT1".data(using: .utf8)!

    public struct ParsedContainer: Equatable, Sendable {
        public var formatVersion: Int
        public var keyDerivation: KeyDerivationParameters
        public var salt: Data
        public var ciphertext: Data

        public init(
            formatVersion: Int,
            keyDerivation: KeyDerivationParameters,
            salt: Data,
            ciphertext: Data
        ) {
            self.formatVersion = formatVersion
            self.keyDerivation = keyDerivation
            self.salt = salt
            self.ciphertext = ciphertext
        }
    }

    public static func build(salt: Data, ciphertext: Data) -> Data {
        guard let defaultIterations = UInt32(exactly: TaprootLimitsV1.defaultPBKDF2Iterations) else {
            preconditionFailure("defaultPBKDF2Iterations must fit in UInt32.")
        }
        guard !salt.isEmpty, salt.count <= Int(UInt8.max) else {
            preconditionFailure("salt length must be within 1...\(UInt8.max)")
        }

        return buildV1(
            salt: salt,
            ciphertext: ciphertext,
            algorithm: .pbkdf2SHA256,
            iterations: defaultIterations
        )
    }

    public static func build(
        salt: Data,
        ciphertext: Data,
        keyDerivation: KeyDerivationParameters
    ) throws -> Data {
        guard
            keyDerivation.iterations >= TaprootLimitsV1.minPBKDF2Iterations,
            keyDerivation.iterations <= TaprootLimitsV1.maxPBKDF2Iterations,
            let iterations = UInt32(exactly: keyDerivation.iterations)
        else {
            throw VaultContainerError.invalidKDFIterations
        }
        guard !salt.isEmpty, salt.count <= Int(UInt8.max) else {
            throw VaultContainerError.invalidSaltLength
        }

        return buildV1(
            salt: salt,
            ciphertext: ciphertext,
            algorithm: keyDerivation.algorithm,
            iterations: iterations
        )
    }

    public static func parse(data: Data) throws -> (salt: Data, ciphertext: Data) {
        let parsed = try parseWithMetadata(data: data)
        return (salt: parsed.salt, ciphertext: parsed.ciphertext)
    }

    public static func parseWithMetadata(data: Data) throws -> ParsedContainer {
        let minimumPossibleContainerLength = magic.count + 1 + 4 + 1 + 1 + 1
        guard data.count >= minimumPossibleContainerLength else {
            throw VaultContainerError.invalidFile
        }

        let magicData = data.prefix(magic.count)
        if magicData == magic {
            return try parseV1(data: data)
        }

        throw VaultContainerError.invalidMagicHeader
    }

    private static func buildV1(
        salt: Data,
        ciphertext: Data,
        algorithm: KeyDerivationAlgorithm,
        iterations: UInt32
    ) -> Data {
        let iterationBytes = [
            UInt8((iterations >> 24) & 0xFF),
            UInt8((iterations >> 16) & 0xFF),
            UInt8((iterations >> 8) & 0xFF),
            UInt8(iterations & 0xFF),
        ]
        let saltLength = UInt8(salt.count)

        var data = Data()
        data.append(magic)
        data.append(algorithm.rawValue)
        data.append(contentsOf: iterationBytes)
        data.append(saltLength)
        data.append(salt)
        data.append(ciphertext)
        return data
    }

    private static func parseV1(data: Data) throws -> ParsedContainer {
        let magicLength = magic.count
        let minimumHeaderLength = magicLength + 1 + 4 + 1
        guard data.count > minimumHeaderLength else {
            throw VaultContainerError.invalidFile
        }

        let algorithmRawValue = data[magicLength]
        guard let algorithm = KeyDerivationAlgorithm(rawValue: algorithmRawValue) else {
            throw VaultContainerError.unsupportedKeyDerivationAlgorithm(rawValue: algorithmRawValue)
        }

        let iterationStartIndex = magicLength + 1
        let iterationEndIndex = iterationStartIndex + 4
        let iterations = data[iterationStartIndex ..< iterationEndIndex]
            .reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        let iterationValue = Int(iterations)
        guard
            iterationValue >= TaprootLimitsV1.minPBKDF2Iterations,
            iterationValue <= TaprootLimitsV1.maxPBKDF2Iterations
        else {
            throw VaultContainerError.invalidKDFIterations
        }

        let saltLengthByte = data[iterationEndIndex]
        guard saltLengthByte > 0 else {
            throw VaultContainerError.invalidSaltLength
        }

        let saltLength = Int(saltLengthByte)
        let saltStartIndex = iterationEndIndex + 1
        let saltEndIndex = saltStartIndex + saltLength
        guard data.count > saltEndIndex else {
            throw VaultContainerError.invalidFile
        }

        let salt = data.subdata(in: saltStartIndex ..< saltEndIndex)
        let ciphertext = data.subdata(in: saltEndIndex ..< data.count)

        return ParsedContainer(
            formatVersion: 1,
            keyDerivation: KeyDerivationParameters(
                algorithm: algorithm,
                iterations: iterationValue
            ),
            salt: salt,
            ciphertext: ciphertext
        )
    }
}

public enum VaultContainerError: Error {
    case invalidFile
    case invalidMagicHeader
    case unsupportedKeyDerivationAlgorithm(rawValue: UInt8)
    case invalidKDFIterations
    case invalidSaltLength
}
