import Crypto
import Foundation

public enum KeyDerivationError: Error {
    case invalidIterationCount
    case keyDerivationFailed(status: Int32)
}

public enum KeyDerivationAlgorithm: UInt8, Codable, Sendable {
    case pbkdf2SHA256 = 1
}

public struct KeyDerivationParameters: Codable, Equatable, Sendable {
    public var algorithm: KeyDerivationAlgorithm
    public var iterations: Int

    public static let `default` = KeyDerivationParameters()

    public init(
        algorithm: KeyDerivationAlgorithm = .pbkdf2SHA256,
        iterations: Int = TaprootLimitsV1.defaultPBKDF2Iterations
    ) {
        self.algorithm = algorithm
        self.iterations = iterations
    }
}

public enum KeyDerivation {
    public static func deriveKey(
        password: String,
        salt: Data,
        iterations: Int = TaprootLimitsV1.defaultPBKDF2Iterations
    ) throws -> SymmetricKey {
        let parameters = KeyDerivationParameters(
            algorithm: .pbkdf2SHA256,
            iterations: iterations
        )

        return try deriveKey(
            password: password,
            salt: salt,
            parameters: parameters
        )
    }

    public static func deriveKey(
        password: String,
        salt: Data,
        parameters: KeyDerivationParameters = .default
    ) throws -> SymmetricKey {
        guard
            parameters.iterations >= TaprootLimitsV1.minPBKDF2Iterations,
            parameters.iterations <= TaprootLimitsV1.maxPBKDF2Iterations
        else {
            throw KeyDerivationError.invalidIterationCount
        }

        let passwordData = Data(password.utf8)

        switch parameters.algorithm {
        case .pbkdf2SHA256:
            let key = try pbkdf2SHA256(
                password: passwordData,
                salt: salt,
                iterations: parameters.iterations,
                keyLength: 32
            )

            return SymmetricKey(data: key)
        }
    }

    private static func pbkdf2SHA256(
        password: Data,
        salt: Data,
        iterations: Int,
        keyLength: Int
    ) throws -> Data {
        let hashLength = 32
        let blockCount = (keyLength + hashLength - 1) / hashLength
        var derivedKey = Data()
        derivedKey.reserveCapacity(blockCount * hashLength)

        for blockIndex in 1 ... blockCount {
            var blockIndexBE = UInt32(blockIndex).bigEndian
            var blockInput = Data(salt)
            withUnsafeBytes(of: &blockIndexBE) { blockInput.append(contentsOf: $0) }

            var u = hmacSHA256(key: password, data: blockInput)
            var t = u

            if iterations > 1 {
                for _ in 2 ... iterations {
                    u = hmacSHA256(key: password, data: Data(u))
                    xorInPlace(&t, with: u)
                }
            }

            derivedKey.append(contentsOf: t)
        }

        return Data(derivedKey.prefix(keyLength))
    }

    private static func hmacSHA256(key: Data, data: Data) -> [UInt8] {
        let authenticationCode = HMAC<SHA256>.authenticationCode(
            for: data,
            using: SymmetricKey(data: key)
        )
        return Array(authenticationCode)
    }

    private static func xorInPlace(_ lhs: inout [UInt8], with rhs: [UInt8]) {
        for index in lhs.indices {
            lhs[index] ^= rhs[index]
        }
    }
}
