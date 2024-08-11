//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A simple in-memory storage class that conforms to `FileStorageRepresentable`.
///
/// `InMemoryStorage` provides a lightweight storage solution that keeps objects
/// in memory using a dictionary. This is useful for temporary storage or testing purposes
/// where persistence is not required.
///
/// - Note: This storage is not persistent and will lose all stored data when the 
/// application terminates.
internal class InMemoryStorage<T>: FileStorageRepresentable where T: Codable {

    private var storage: [String: T] = [:]

    /// Initializes a new `InMemoryStorage` instance.
    ///
    /// This initializer creates an empty in-memory storage.
    internal init() {}

    /// Saves an object to in-memory storage under the specified identifier.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Codable`.
    ///   - identifier: The key under which the object will be stored.
    internal func save(_ object: T, with identifier: String) async throws {
        storage[identifier] = object
    }

    /// Loads an object from in-memory storage with the specified identifier.
    ///
    /// - Parameter identifier: The key of the object to load.
    /// - Returns: The loaded object, or `nil` if no object was found for the given identifier.
    internal func load(file identifier: String) async throws -> T? {
        return storage[identifier]
    }

    /// Deletes an object from in-memory storage with the specified identifier.
    ///
    /// - Parameter identifier: The key of the object to delete.
    internal func delete(file identifier: String) async throws {
        storage.removeValue(forKey: identifier)
    }

    /// Lists all identifiers (keys) of objects currently stored in memory.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    internal func listAllIdentifiers() async throws -> [String] {
        return Array(storage.keys)
    }
}
