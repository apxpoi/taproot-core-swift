import CommonCrypto
import CryptoKit
import Foundation

public enum KeyDerivationError: Error {
    case invalidIterationCount
    case keyDerivationFailed(status: Int32)
}

public enum KeyDerivation {
    public static func deriveKey(
        password: String,
        salt: Data,
        iterations: Int = TaprootLimitsV1.defaultPBKDF2Iterations
    ) throws -> SymmetricKey {
        guard iterations > 0 else {
            throw KeyDerivationError.invalidIterationCount
        }

        let passwordData = Data(password.utf8)

        let key = try pbkdf2SHA256(
            password: passwordData,
            salt: salt,
            iterations: iterations,
            keyLength: 32
        )

        return SymmetricKey(data: key)
    }

    private static func pbkdf2SHA256(
        password: Data,
        salt: Data,
        iterations: Int,
        keyLength: Int
    ) throws -> Data {
        var derivedKey = Data(count: keyLength)

        let status = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            let derivedKeyBytesPointer = derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress!

            return password.withUnsafeBytes { passwordBytes in
                let passwordPointer = passwordBytes.bindMemory(to: Int8.self).baseAddress!

                return salt.withUnsafeBytes { saltBytes in
                    let saltPointer = saltBytes.bindMemory(to: UInt8.self).baseAddress!

                    return CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordPointer,
                        password.count,
                        saltPointer,
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        derivedKeyBytesPointer,
                        keyLength
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw KeyDerivationError.keyDerivationFailed(status: status)
        }

        return derivedKey
    }
}
