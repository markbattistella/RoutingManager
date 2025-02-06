//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A file storage implementation that saves and loads data in JSON format.
///
/// `JSONFileStorage` conforms to `FileStorageRepresentable` and provides methods for persisting,
/// retrieving, and deleting `Codable` objects from a file in the user's document directory.
internal struct JSONFileStorage<T: Codable>: FileStorageRepresentable {

    /// The file URL where the JSON data is stored.
    private let fileURL: URL

    /// Initializes a new `JSONFileStorage` instance with a specified file name.
    ///
    /// - Parameter fileName: The name of the file where data will be stored. Defaults to
    /// "NavigationState.json"`.
    internal init(fileName: String = "NavigationState.json") {
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    /// Saves an object to the file in JSON format.
    ///
    /// - Parameter object: The object to be encoded and saved.
    /// - Throws: An error if encoding fails or if the file cannot be written.
    internal func save(_ object: T) throws {
        let data = try JSONEncoder().encode(object)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Loads an object from the file if it exists.
    ///
    /// - Returns: The decoded object if the file exists and is valid, otherwise `nil`.
    /// - Throws: A `NavigationError.load` error if decoding fails.
    internal func load() throws -> T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        let data = try Data(contentsOf: fileURL)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NavigationError.load(error)
        }
    }

    /// Deletes the stored file if it exists.
    ///
    /// - Throws: An error if the file cannot be deleted.
    internal func delete() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }
}
