//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A file-based storage class that saves objects in JSON format, conforming to
/// `FileStorageRepresentable`.
///
/// `JSONFileStorage` provides a way to persist objects to the file system using JSON encoding.
/// This class supports saving, loading, deleting, and listing objects by their identifiers, with
/// an optional file prefix for distinguishing different types of data.
///
/// - Note: Objects are stored in the specified directory as JSON files, with an optional prefix
/// to prevent conflicts between different types of stored data.
internal class JSONFileStorage<T>: FileStorageRepresentable where T: Codable {

    private let fileManager = FileManager.default
    private let directory: URL
    private let filePrefix: String?

    /// Initializes a new `JSONFileStorage` instance with an optional file prefix.
    ///
    /// - Parameters:
    ///   - directory: The directory in which to store JSON files. Defaults to `.documentDirectory`.
    ///   - filePrefix: An optional prefix to prepend to all file names, ensuring uniqueness
    ///   and separation.
    internal init(
        directory: FileManager.SearchPathDirectory = .documentDirectory,
        filePrefix: String? = nil
    ) {
        self.directory = fileManager.urls(for: directory, in: .userDomainMask).first!
        self.filePrefix = filePrefix
    }

    /// Returns the file URL for a given identifier by appending the `.json` extension and an
    /// optional prefix.
    ///
    /// - Parameter identifier: The key used to identify the object.
    /// - Returns: A URL pointing to the file location in the specified directory.
    private func fileURL(for identifier: String) -> URL {
        let prefixedIdentifier = filePrefix.map { "\($0)\(identifier)" } ?? identifier
        return directory
            .appendingPathComponent(prefixedIdentifier)
            .appendingPathExtension("json")
    }

    /// Saves an object to the file system as a JSON file with the specified identifier.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Codable`.
    ///   - identifier: The key under which the object will be saved.
    /// - Throws: An error if the save operation fails.
    internal func save(_ object: T, with identifier: String) async throws {
        let data = try JSONEncoder().encode(object)
        let url = fileURL(for: identifier)
        try data.write(to: url)
    }

    /// Loads an object from the file system with the specified identifier.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    /// - Throws: An error if the load operation fails.
    internal func load(file identifier: String) async throws -> T? {
        let url = fileURL(for: identifier)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Deletes an object from the file system with the specified identifier.
    ///
    /// - Parameter identifier: The key of the object to delete.
    /// - Throws: An error if the delete operation fails.
    internal func delete(file identifier: String) async throws {
        let url = fileURL(for: identifier)
        try fileManager.removeItem(at: url)
    }

    /// Lists all identifiers (file names without the `.json` extension) of objects currently
    /// stored in the directory.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    /// - Throws: An error if the list operation fails.
    internal func listAllIdentifiers() async throws -> [String] {
        let files = try fileManager.contentsOfDirectory(atPath: directory.path)
        return files
            .filter { $0.hasPrefix(filePrefix ?? "") }
            .map { $0
                .replacingOccurrences(of: ".json", with: "")
                .replacingOccurrences(of: filePrefix ?? "", with: "")
            }
    }
}
