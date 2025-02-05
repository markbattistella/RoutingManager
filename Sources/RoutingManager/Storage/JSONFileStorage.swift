//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A concrete implementation of `FileStorageRepresentable` that persists data as a JSON file.
///
/// This struct provides methods to save, load, and delete `Codable` objects from a file stored
/// in the user's document directory.
public struct JSONFileStorage<T: Codable>: FileStorageRepresentable {

    /// The file URL where the JSON data is stored.
    private let fileURL: URL

    /// Initializes a `JSONFileStorage` instance with an optional file name.
    ///
    /// - Parameter fileName: The name of the JSON file to be used for storage.
    ///   Defaults to `"NavigationState.json"`.
    public init(fileName: String = "NavigationState.json") {
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    /// Saves an object to a JSON file.
    ///
    /// - Parameter object: The `Codable` object to be saved.
    /// - Throws: An error if encoding the object or writing to the file fails.
    public func save(_ object: T) async throws {
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Loads an object from the JSON file.
    ///
    /// - Returns: The decoded object if the file exists, otherwise `nil`.
    /// - Throws: A `NavigationError.load` error if decoding fails.
    public func load() async throws -> T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NavigationError.load(error)
        }
    }

    /// Deletes the JSON file from storage.
    ///
    /// - Throws: An error if the deletion operation fails.
    public func delete() async throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
