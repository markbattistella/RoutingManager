//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An in-memory storage implementation for temporary data persistence.
///
/// `MemoryStorage` conforms to `FileStorageRepresentable` and provides methods for saving,
/// loading, and deleting `Codable` objects, storing them in memory.
internal final class MemoryStorage<T: Codable>: FileStorageRepresentable {

    /// The in-memory storage for the object.
    private var storage: T?

    /// Initializes a new `MemoryStorage` instance.
    internal init() {}

    /// Saves an object to in-memory storage.
    ///
    /// - Parameter object: The object to be stored.
    /// - Throws: No errors are thrown in this implementation.
    internal func save(_ object: T) throws {
        storage = object
    }

    /// Loads an object from in-memory storage.
    ///
    /// - Returns: The stored object if available, otherwise `nil`.
    /// - Throws: No errors are thrown in this implementation.
    internal func load() throws -> T? {
        return storage
    }

    /// Deletes the stored object from memory.
    ///
    /// - Throws: No errors are thrown in this implementation.
    internal func delete() throws {
        storage = nil
    }
}
