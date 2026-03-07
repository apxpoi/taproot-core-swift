import Crypto
import Foundation
#if canImport(Security)
    import Security
#endif

public enum VaultCryptoError: Error {
    case encryptionFailed
    case randomBufferUnavailable
    case randomGenerationFailed(status: Int32)
}

public enum VaultCrypto {
    public static func encrypt(
        vault: Vault,
        password: String,
        keyDerivation: KeyDerivationParameters = .default
    ) throws -> Data {
        try vault.validate()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(vault)

        let salt = try randomData(length: 16)
        let key = try KeyDerivation.deriveKey(
            password: password,
            salt: salt,
            parameters: keyDerivation
        )

        let sealedBox = try AES.GCM.seal(jsonData, using: key)

        guard let combined = sealedBox.combined else {
            throw VaultCryptoError.encryptionFailed
        }

        return try VaultContainer.build(
            salt: salt,
            ciphertext: combined,
            keyDerivation: keyDerivation
        )
    }

    public static func decrypt(
        data: Data,
        password: String
    ) throws -> Vault {
        let container = try VaultContainer.parseWithMetadata(data: data)

        let key = try KeyDerivation.deriveKey(
            password: password,
            salt: container.salt,
            parameters: container.keyDerivation
        )

        let sealedBox = try AES.GCM.SealedBox(combined: container.ciphertext)
        let decrypted = try AES.GCM.open(sealedBox, using: key)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let vault = try decoder.decode(Vault.self, from: decrypted)
        try vault.validate()
        return vault
    }

    private static func randomData(length: Int) throws -> Data {
        #if canImport(Security)
            var data = Data(count: length)

            let status = try data.withUnsafeMutableBytes { buffer -> Int32 in
                guard let baseAddress = buffer.baseAddress else {
                    throw VaultCryptoError.randomBufferUnavailable
                }

                return SecRandomCopyBytes(kSecRandomDefault, length, baseAddress)
            }

            guard status == 0 else {
                throw VaultCryptoError.randomGenerationFailed(status: status)
            }

            return data
        #else
            var generator = SystemRandomNumberGenerator()
            var bytes = [UInt8]()
            bytes.reserveCapacity(length)

            for _ in 0 ..< length {
                bytes.append(UInt8.random(in: UInt8.min ... UInt8.max, using: &generator))
            }

            return Data(bytes)
        #endif
    }
}
