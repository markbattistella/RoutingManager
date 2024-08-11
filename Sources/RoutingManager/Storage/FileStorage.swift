//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A type-erased storage wrapper that allows for the use of different storage implementations
/// without exposing the underlying storage type.
///
/// `FileStorage` provides a uniform interface for saving, loading, deleting, and listing
/// items stored using any storage that conforms to `FileStorageRepresentable`.
///
/// - Note: This class uses generics to support any type `T` that conforms to `Serializable`.
@MainActor
public final class FileStorage<T> where T: Serializable {
    private let _save: (T, String) async throws -> Void
    private let _load: (String) async throws -> T?
    private let _delete: (String) async throws -> Void
    private let _listAllIdentifiers: () async throws -> [String]

    /// Initializes a new `FileStorage` instance that wraps the given storage implementation.
    ///
    /// - Parameter storage: A storage instance conforming to `FileStorageRepresentable`.
    ///   This storage instance determines how data is saved, loaded, and deleted.
    public init<U>(_ storage: U) where T == U.T, U: FileStorageRepresentable, U: Sendable {
        self._save = storage.save
        self._load = storage.load
        self._delete = storage.delete
        self._listAllIdentifiers = storage.listAllIdentifiers
    }

    /// Saves an object to storage under the specified file name.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Serializable`.
    ///   - fileName: The name under which the object will be saved.
    /// - Throws: An error if the save operation fails.
    public func save(_ object: T, as fileName: String) async throws {
        try await _save(object, fileName)
    }

    /// Loads an object from storage with the specified file name.
    ///
    /// - Parameter fileName: The name of the file from which to load the object.
    /// - Returns: The loaded object, or `nil` if the object could not be found.
    /// - Throws: An error if the load operation fails.
    public func load(for fileName: String) async throws -> T? {
        return try await _load(fileName)
    }

    /// Deletes an object from storage with the specified file name.
    ///
    /// - Parameter fileName: The name of the file to delete.
    /// - Throws: An error if the delete operation fails.
    public func delete(for fileName: String) async throws {
        try await _delete(fileName)
    }

    /// Lists all identifiers (file names) of objects currently stored.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    /// - Throws: An error if the list operation fails.
    public func listAllIdentifiers() async throws -> [String] {
        return try await _listAllIdentifiers()
    }
}

extension FileStorage: Sendable {}
