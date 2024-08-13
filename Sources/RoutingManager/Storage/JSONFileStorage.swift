//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A JSON-based file storage class that conforms to `FileStorageRepresentable`, providing methods
/// to save, load, delete, and list objects stored as JSON files in the file system.
///
/// `JSONFileStorage` leverages an actor to ensure that all file operations are thread-safe and
/// occur in a serialized manner. This class is ideal for scenarios where persistent storage with
/// JSON serialization is required, offering a straightforward way to manage data across
/// application sessions.
///
/// - Note: The objects managed by this class must conform to `Serializable`, ensuring that they
///   can be properly serialized and deserialized for consistent storage and retrieval.
internal final class JSONFileStorage<T>: FileStorageRepresentable where T: Serializable {
    
    /// The directory where JSON files will be stored.
    private let directory: URL
    
    /// An optional prefix to prepend to all file names, ensuring uniqueness and separation.
    private let filePrefix: String?
    
    /// The actor instance managing file operations.
    ///
    /// This actor instance is responsible for handling all file operations in a thread-safe
    /// and serialized manner.
    private let fileActor: FileActor
    
    /// Initializes a new `JSONFileStorage` instance with an optional file prefix.
    ///
    /// - Parameters:
    ///   - directory: The directory in which to store JSON files. Defaults to `.documentDirectory`.
    ///   - filePrefix: An optional prefix to prepend to all file names, ensuring uniqueness and
    ///     separation.
    internal init(
        directory: FileManager.SearchPathDirectory = .documentDirectory,
        filePrefix: String? = nil
    ) {
        let dir = FileManager.default.urls(for: directory, in: .userDomainMask).first!
        self.directory = dir
        self.filePrefix = filePrefix
        self.fileActor = FileActor(directory: dir, filePrefix: filePrefix)
    }
}

fileprivate extension JSONFileStorage {
    
    /// An actor responsible for managing file operations.
    ///
    /// The `FileActor` ensures that all file operations are thread-safe and occur in a
    /// serialized manner.
    actor FileActor {
        
        /// The directory where JSON files will be stored.
        private let directory: URL
        
        /// An optional prefix to prepend to all file names, ensuring uniqueness and separation.
        private let filePrefix: String?
        
        /// Initializes the `FileActor` with the specified directory and file prefix.
        ///
        /// - Parameters:
        ///   - directory: The directory where JSON files will be stored.
        ///   - filePrefix: An optional prefix to prepend to all file names.
        init(directory: URL, filePrefix: String?) {
            self.directory = directory
            self.filePrefix = filePrefix
        }
    }
}

fileprivate extension JSONFileStorage.FileActor {
    
    /// Returns the file URL for a given identifier by appending the `.json` extension and
    /// an optional prefix.
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
    ///   - object: The object to save. This object must conform to `Serializable`.
    ///   - identifier: The key under which the object will be saved.
    /// - Throws: An error if the save operation fails.
    func save(_ object: T, with identifier: String) throws {
        let data = try JSONEncoder().encode(object)
        let url = fileURL(for: identifier)
        try data.write(to: url)
    }
    
    /// Loads an object from the file system with the specified identifier.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    /// - Throws: An error if the load operation fails.
    func load(file identifier: String) throws -> T? {
        let url = fileURL(for: identifier)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// Deletes an object from the file system with the specified identifier.
    ///
    /// - Parameter identifier: The key of the object to delete.
    /// - Throws: An error if the delete operation fails.
    func delete(file identifier: String) throws {
        let url = fileURL(for: identifier)
        try FileManager.default.removeItem(at: url)
    }
    
    /// Lists all identifiers (file names without the `.json` extension) of objects currently
    /// stored in the directory.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    /// - Throws: An error if the list operation fails.
    func listAllIdentifiers() throws -> [String] {
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        return files
            .filter { $0.hasPrefix(filePrefix ?? "") }
            .map { $0
                .replacingOccurrences(of: ".json", with: "")
                .replacingOccurrences(of: filePrefix ?? "", with: "")
            }
    }
}

internal extension JSONFileStorage {
    
    /// Saves an object to the file system as a JSON file with the specified identifier.
    ///
    /// This method asynchronously saves the provided object to the file system.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Serializable`.
    ///   - identifier: The key under which the object will be saved.
    /// - Throws: An error if the save operation fails.
    func save(_ object: T, with identifier: String) async throws {
        try await fileActor.save(object, with: identifier)
    }
    
    /// Loads an object from the file system with the specified identifier.
    ///
    /// This method asynchronously retrieves the object associated with the provided identifier
    /// from the file system.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    /// - Throws: An error if the load operation fails.
    func load(file identifier: String) async throws -> T? {
        return try await fileActor.load(file: identifier)
    }
    
    /// Deletes an object from the file system with the specified identifier.
    ///
    /// This method asynchronously removes the object associated with the provided identifier
    /// from the file system.
    ///
    /// - Parameter identifier: The key of the object to delete.
    /// - Throws: An error if the delete operation fails.
    func delete(file identifier: String) async throws {
        try await fileActor.delete(file: identifier)
    }
    
    /// Lists all identifiers (file names without the `.json` extension) of objects currently
    /// stored in the directory.
    ///
    /// This method asynchronously retrieves all the keys of the objects stored in the directory.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    /// - Throws: An error if the list operation fails.
    func listAllIdentifiers() async throws -> [String] {
        return try await fileActor.listAllIdentifiers()
    }
}

extension JSONFileStorage: Sendable {}
