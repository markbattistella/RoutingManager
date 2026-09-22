//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A file storage implementation that saves and loads data in JSON format.
///
/// `JSONFileStorage` resolves its location lazily and reports filesystem failures to callers
/// instead of trapping. Parent directories are created before the first save.
internal struct JSONFileStorage<T: Codable>: FileStorageRepresentable {
    private let fileName: String
    private let directoryURL: URL?

    /// Initializes a new JSON store in the user's documents directory.
    ///
    /// - Parameter fileName: A relative filename or path. Defaults to `NavigationState.json`.
    internal init(
        fileName: String = "NavigationState.json",
        directoryURL: URL? = nil
    ) {
        self.fileName = fileName
        self.directoryURL = directoryURL
    }

    internal func save(_ object: T) throws {
        let fileURL = try resolveFileURL(createDirectory: true)
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL, options: .atomic)
    }

    internal func load() throws -> T? {
        let fileURL = try resolveFileURL(createDirectory: false)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        }
        catch let error as NavigationError {
            throw error
        }
        catch {
            throw NavigationError.load(error)
        }
    }

    internal func delete() throws {
        let fileURL = try resolveFileURL(createDirectory: false)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }

    private func resolveFileURL(createDirectory: Bool) throws -> URL {
        let fileManager = FileManager.default
        let documentsURL =
            try directoryURL
            ?? fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: createDirectory
            )
        let fileURL = documentsURL.appendingPathComponent(fileName, isDirectory: false)

        if createDirectory {
            try fileManager.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        }

        return fileURL
    }
}
