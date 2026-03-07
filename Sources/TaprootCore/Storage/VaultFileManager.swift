import Foundation

public enum VaultFileError: Error {
    case vaultNotFound
    case invalidFileURL
    case invalidFileName
}

public enum VaultFileManager {
    public static func save(
        encryptedData: Data,
        named fileName: String
    ) throws {
        let _url = try url(for: fileName)
        try encryptedData.write(to: _url, options: .atomic)
    }

    public static func load(
        named fileName: String
    ) throws -> Data {
        let _url = try url(for: fileName)

        guard FileManager.default.fileExists(atPath: _url.path) else {
            throw VaultFileError.vaultNotFound
        }

        return try Data(contentsOf: _url)
    }

    public static func delete(
        named fileName: String
    ) throws {
        let _url = try url(for: fileName)

        guard FileManager.default.fileExists(atPath: _url.path) else {
            throw VaultFileError.vaultNotFound
        }

        try FileManager.default.removeItem(at: _url)
    }

    public static func exists(
        named fileName: String
    ) throws -> Bool {
        let _url = try url(for: fileName)
        return FileManager.default.fileExists(atPath: _url.path)
    }

    public static func list() throws -> [String] {
        let _directory = try directory()

        let files = try FileManager.default.contentsOfDirectory(
            at: _directory,
            includingPropertiesForKeys: nil
        )

        return files
            .filter { $0.pathExtension == "tdf" }
            .map { $0.deletingPathExtension().lastPathComponent }
    }

    private static func url(for fileName: String) throws -> URL {
        let safeFileName = try sanitize(fileName: fileName)
        let _directory = try directory()
        return _directory.appendingPathComponent(safeFileName)
            .appendingPathExtension("tdf")
    }

    private static func sanitize(fileName: String) throws -> String {
        let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw VaultFileError.invalidFileName
        }

        guard trimmed != ".", trimmed != ".." else {
            throw VaultFileError.invalidFileName
        }

        guard !trimmed.contains("/"), !trimmed.contains("\\") else {
            throw VaultFileError.invalidFileName
        }

        let lastPathComponent = URL(fileURLWithPath: trimmed).lastPathComponent
        guard lastPathComponent == trimmed else {
            throw VaultFileError.invalidFileName
        }

        return trimmed
    }

    private static func directory() throws -> URL {
        guard let _url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw VaultFileError.invalidFileURL
        }

        let vaultFolder = _url.appendingPathComponent("Taproot")

        if !FileManager.default.fileExists(atPath: vaultFolder.path) {
            try FileManager.default.createDirectory(
                at: vaultFolder,
                withIntermediateDirectories: true
            )
        }

        return vaultFolder
    }
}
