import Foundation

public enum VaultContainer {
    static let magic = "TAPROOT1".data(using: .utf8)!

    public static func build(salt: Data, ciphertext: Data) -> Data {
        var data = Data()
        data.append(magic)
        data.append(salt)
        data.append(ciphertext)
        return data
    }

    public static func parse(data: Data) throws -> (salt: Data, ciphertext: Data) {
        let magicLength = magic.count
        let saltLength = 16

        guard data.count > magicLength + saltLength else {
            throw VaultContainerError.invalidFile
        }

        let magicData = data.prefix(magicLength)
        guard magicData == magic else {
            throw VaultContainerError.invalidMagicHeader
        }

        let salt = data.subdata(in: magicLength ..< (magicLength + saltLength))
        let ciphertext = data.subdata(in: (magicLength + saltLength) ..< data.count)

        return (salt: salt, ciphertext: ciphertext)
    }
}

public enum VaultContainerError: Error {
    case invalidFile
    case invalidMagicHeader
}
