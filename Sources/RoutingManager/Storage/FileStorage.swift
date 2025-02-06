//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A generic file storage wrapper that conforms to `FileStorageRepresentable`.
///
/// `FileStorage` acts as an abstraction layer, delegating storage operations (save, load, and
/// delete) to a specific storage implementation.
public final class FileStorage<T: Codable>: FileStorageRepresentable {

    /// A closure responsible for saving an object.
    private let saveFunction: (T) throws -> Void

    /// A closure responsible for loading an object.
    private let loadFunction: () throws -> T?

    /// A closure responsible for deleting stored data.
    private let deleteFunction: () throws -> Void

    /// Initializes a `FileStorage` instance with a specific storage implementation.
    ///
    /// - Parameter storage: A storage implementation that conforms to `FileStorageRepresentable`.
    public init<U: FileStorageRepresentable>(_ storage: U) where U.T == T {
        self.saveFunction = storage.save
        self.loadFunction = storage.load
        self.deleteFunction = storage.delete
    }

    /// Saves an object to storage.
    ///
    /// - Parameter object: The object to be saved.
    /// - Throws: An error if the save operation fails.
    public func save(_ object: T) throws {
        try saveFunction(object)
    }

    /// Loads an object from storage.
    ///
    /// - Returns: The loaded object if available, otherwise `nil`.
    /// - Throws: An error if the load operation fails.
    public func load() throws -> T? {
        try loadFunction()
    }

    /// Deletes the stored object from storage.
    ///
    /// - Throws: An error if the delete operation fails.
    public func delete() throws {
        try deleteFunction()
    }
}
