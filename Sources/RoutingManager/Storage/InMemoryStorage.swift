//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A thread-safe, in-memory storage class for storing and retrieving objects conforming to 
/// `Serializable`.
///
/// This class uses an internal actor to ensure that all operations on the storage are performed 
/// safely in a concurrent environment.
internal final class InMemoryStorage<T>: FileStorageRepresentable where T: Serializable {

    /// An actor responsible for managing the storage dictionary.
    ///
    /// The `StorageActor` ensures that all operations on the storage dictionary are thread-safe 
    /// and occur in a serialized manner.
    private actor StorageActor {
        
        private var storage: [String: T] = [:]
        
        /// Updates the entire storage dictionary with a new value.
        ///
        /// - Parameter newValue: A dictionary containing the new storage values.
        func updateStorage(_ newValue: [String: T]) { storage = newValue }
        
        /// Retrieves the entire storage dictionary.
        ///
        /// - Returns: The current storage dictionary.
        func getStorage() -> [String: T] { storage }
        
        /// Saves an object to the storage under the specified identifier.
        ///
        /// - Parameters:
        ///   - object: The object to save.
        ///   - identifier: The key under which the object will be stored.
        func save(_ object: T, with identifier: String) { storage[identifier] = object }
        
        /// Loads an object from the storage with the specified identifier.
        ///
        /// - Parameter identifier: The key of the object to load.
        /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
        func load(file identifier: String) -> T? { storage[identifier] }
        
        /// Deletes an object from the storage with the specified identifier.
        ///
        /// - Parameter identifier: The key of the object to delete.
        func delete(file identifier: String) { storage.removeValue(forKey: identifier) }
        
        /// Lists all identifiers (keys) of objects currently stored in memory.
        ///
        /// - Returns: An array of strings representing the identifiers of all stored objects.
        func listAllIdentifiers() -> [String] { Array(storage.keys) }
    }
    
    /// The actor instance managing the storage.
    private let storageActor = StorageActor()
    
    /// Initializes a new `InMemoryStorage` instance.
    ///
    /// This initializer creates an empty in-memory storage.
    internal init() {}
    
    /// Saves an object to in-memory storage under the specified identifier.
    ///
    /// This method asynchronously saves the provided object to the storage dictionary.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Serializable`.
    ///   - identifier: The key under which the object will be stored.
    internal func save(_ object: T, with identifier: String) async throws {
        await storageActor.save(object, with: identifier)
    }
    
    /// Loads an object from in-memory storage with the specified identifier.
    ///
    /// This method asynchronously retrieves the object associated with the provided identifier 
    /// from the storage.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    internal func load(file identifier: String) async throws -> T? {
        return await storageActor.load(file: identifier)
    }
    
    /// Deletes an object from in-memory storage with the specified identifier.
    ///
    /// This method asynchronously removes the object associated with the provided identifier 
    /// from the storage.
    ///
    /// - Parameter identifier: The key of the object to delete.
    internal func delete(file identifier: String) async throws {
        await storageActor.delete(file: identifier)
    }
    
    /// Lists all identifiers (keys) of objects currently stored in memory.
    ///
    /// This method asynchronously retrieves all the keys of the objects stored in the storage.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    internal func listAllIdentifiers() async throws -> [String] {
        return await storageActor.listAllIdentifiers()
    }
}

extension InMemoryStorage: Sendable {}
