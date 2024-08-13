//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A generic class for managing file storage operations, providing methods to save, load, delete,
/// and list objects in a storage system.
///
/// `FileStorage` wraps an underlying storage implementation that conforms to the
/// `FileStorageRepresentable` protocol. This allows for flexible storage mechanisms while
/// providing a consistent API for file storage operations. The class is designed to be thread-safe
/// and supports asynchronous operations using `async` and `throws`.
///
/// - Note: The objects managed by this class must conform to `Serializable`, ensuring that they
/// can be serialized and deserialized for storage and retrieval.
public final class FileStorage<T> where T: Serializable {

    private let _save: @Sendable (T, String) async throws -> Void
    private let _load: @Sendable (String) async throws -> T?
    private let _delete: @Sendable (String) async throws -> Void
    private let _listAllIdentifiers: @Sendable () async throws -> [String]

    /// Initializes a new `FileStorage` instance that wraps the given storage implementation.
    ///
    /// This initializer accepts a storage instance that conforms to `FileStorageRepresentable`,
    /// determining how data is saved, loaded, and deleted. The initializer captures the storage
    /// instance's methods, enabling the `FileStorage` class to delegate its operations to the
    /// underlying storage implementation.
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
    /// This method asynchronously saves the provided object to storage using the specified file
    /// name. The object must conform to `Serializable` to ensure it can be properly serialized
    /// and stored. If the save operation fails, an error is thrown.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Serializable`.
    ///   - fileName: The name under which the object will be saved. This name is used to retrieve,
    ///     update, or delete the object in future operations.
    /// - Throws: An error if the save operation fails, such as due to write permissions,
    ///   serialization errors, or disk space issues.
    public func save(_ object: T, as fileName: String) async throws {
        try await _save(object, fileName)
    }

    /// Loads an object from storage with the specified file name.
    ///
    /// This method asynchronously loads an object from storage using the provided file name. If
    /// the file does not exist or cannot be read, the method returns `nil`. The object must conform
    /// to `Serializable` to ensure it can be properly deserialized. If the load operation fails,
    /// an error is thrown.
    ///
    /// - Parameter fileName: The name of the file from which to load the object.
    /// - Returns: The loaded object, or `nil` if the object could not be found.
    /// - Throws: An error if the load operation fails, such as due to read permissions, file
    ///   corruption, or missing files.
    public func load(for fileName: String) async throws -> T? {
        return try await _load(fileName)
    }

    /// Deletes an object from storage with the specified file name.
    ///
    /// This method asynchronously deletes the object associated with the given file name from
    /// storage. If the delete operation fails, an error is thrown. This is useful for removing
    /// outdated or no longer needed data.
    ///
    /// - Parameter fileName: The name of the file to delete. This file name should match the name
    ///     used when the object was saved.
    /// - Throws: An error if the delete operation fails, such as due to file permissions, file
    ///   locks, or non-existent files.
    public func delete(for fileName: String) async throws {
        try await _delete(fileName)
    }

    /// Lists all identifiers (file names) of objects currently stored.
    ///
    /// This method asynchronously retrieves a list of all file names currently stored in the
    /// system. These file names can be used to load, update, or delete the corresponding objects.
    /// If the listing operation fails, an error is thrown.
    ///
    /// - Returns: An array of strings representing the identifiers (file names) of all stored
    ///   objects.
    /// - Throws: An error if the list operation fails, such as due to read permissions or
    ///   directory access issues.
    public func listAllIdentifiers() async throws -> [String] {
        return try await _listAllIdentifiers()
    }
}

extension FileStorage: Sendable {}
