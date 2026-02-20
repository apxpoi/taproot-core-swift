import CryptoKit
import Foundation

public enum VaultCryptoError: Error {
    case encryptionFailed
    case randomBufferUnavailable
    case randomGenerationFailed(status: Int32)
}

public enum VaultCrypto {
    public static func encrypt(
        vault: Vault,
        password: String
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let jsonData = try encoder.encode(vault)

        let salt = try randomData(length: 16)
        let key = try KeyDerivation.deriveKey(password: password, salt: salt)

        let sealedBox = try AES.GCM.seal(jsonData, using: key)

        guard let combined = sealedBox.combined else {
            throw VaultCryptoError.encryptionFailed
        }

        return VaultContainer.build(
            salt: salt,
            ciphertext: combined
        )
    }

    public static func decrypt(
        data: Data,
        password: String
    ) throws -> Vault {
        let container = try VaultContainer.parse(data: data)

        let key = try KeyDerivation.deriveKey(password: password, salt: container.salt)

        let sealedBox = try AES.GCM.SealedBox(combined: container.ciphertext)
        let decrypted = try AES.GCM.open(sealedBox, using: key)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Vault.self, from: decrypted)
    }

    private static func randomData(length: Int) throws -> Data {
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
    }
}
