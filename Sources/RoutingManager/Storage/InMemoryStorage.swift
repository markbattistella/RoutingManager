//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An in-memory storage class that conforms to `FileStorageRepresentable`, providing methods to
/// save, load, delete, and list objects stored in memory.
///
/// `InMemoryStorage` uses an actor to ensure that all operations on the storage dictionary are
/// thread-safe and occur in a serialized manner. This class is useful for scenarios where data
/// persistence is needed without the overhead of disk I/O, making it suitable for caching or
/// temporary data storage.
///
/// - Note: The objects managed by this class must conform to `Serializable`, ensuring that they
/// can be properly serialized for consistent storage and retrieval.
internal final class InMemoryStorage<T>: FileStorageRepresentable where T: Serializable {

    /// An actor responsible for managing the storage dictionary.
    ///
    /// The `StorageActor` ensures that all operations on the storage dictionary are thread-safe
    /// and occur in a serialized manner, preventing data races and ensuring consistency.
    fileprivate actor StorageActor {

        /// The underlying storage dictionary.
        ///
        /// Keys represent the identifiers of stored objects, and values are the objects themselves.
        private var storage: [String: T] = [:]
    }

    /// The actor instance managing the storage.
    ///
    /// This actor instance is responsible for handling all interactions with the storage
    /// dictionary, ensuring that these interactions are thread-safe.
    private let storageActor = StorageActor()

    /// Initializes a new `InMemoryStorage` instance.
    ///
    /// This initializer creates an empty in-memory storage, ready to store and manage objects.
    internal init() {}
}

fileprivate extension InMemoryStorage.StorageActor {

    /// Updates the entire storage dictionary with a new value.
    ///
    /// This method replaces the current storage dictionary with a new one, which can be useful
    /// for bulk updates or resetting the storage.
    ///
    /// - Parameter newValue: A dictionary containing the new storage values.
    func updateStorage(_ newValue: [String: T]) {
        storage = newValue
    }

    /// Retrieves the entire storage dictionary.
    ///
    /// - Returns: The current storage dictionary.
    func getStorage() -> [String: T] {
        return storage
    }

    /// Saves an object to the storage under the specified identifier.
    ///
    /// This method adds or updates the object associated with the given identifier in the
    /// storage dictionary.
    ///
    /// - Parameters:
    ///   - object: The object to save.
    ///   - identifier: The key under which the object will be stored.
    func save(_ object: T, with identifier: String) {
        storage[identifier] = object
    }

    /// Loads an object from the storage with the specified identifier.
    ///
    /// This method retrieves the object associated with the given identifier from the storage
    /// dictionary.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    func load(file identifier: String) -> T? {
        return storage[identifier]
    }

    /// Deletes an object from the storage with the specified identifier.
    ///
    /// This method removes the object associated with the given identifier from the storage
    /// dictionary.
    ///
    /// - Parameter identifier: The key of the object to delete.
    func delete(file identifier: String) {
        storage.removeValue(forKey: identifier)
    }

    /// Lists all identifiers (keys) of objects currently stored in memory.
    ///
    /// This method retrieves all the keys (identifiers) currently used in the storage
    /// dictionary, allowing you to see which objects are stored.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    func listAllIdentifiers() -> [String] {
        return Array(storage.keys)
    }
}

internal extension InMemoryStorage {

    /// Saves an object to in-memory storage under the specified identifier.
    ///
    /// This method asynchronously saves the provided object to the storage dictionary. The object
    /// is stored under the given identifier, which can be used later to retrieve or delete it.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Serializable`.
    ///   - identifier: The key under which the object will be stored.
    func save(_ object: T, with identifier: String) async throws {
        await storageActor.save(object, with: identifier)
    }

    /// Loads an object from in-memory storage with the specified identifier.
    ///
    /// This method asynchronously retrieves the object associated with the provided identifier
    /// from the storage. If no object is found for the identifier, the method returns `nil`.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    func load(file identifier: String) async throws -> T? {
        return await storageActor.load(file: identifier)
    }

    /// Deletes an object from in-memory storage with the specified identifier.
    ///
    /// This method asynchronously removes the object associated with the provided identifier
    /// from the storage. If no object is found for the identifier, no action is taken.
    ///
    /// - Parameter identifier: The key of the object to delete.
    func delete(file identifier: String) async throws {
        await storageActor.delete(file: identifier)
    }

    /// Lists all identifiers (keys) of objects currently stored in memory.
    ///
    /// This method asynchronously retrieves all the keys of the objects stored in the storage,
    /// allowing you to see which objects are currently stored.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    func listAllIdentifiers() async throws -> [String] {
        return await storageActor.listAllIdentifiers()
    }
}

extension InMemoryStorage: Sendable {}
