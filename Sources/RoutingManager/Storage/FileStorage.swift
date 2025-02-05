//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A generic file storage wrapper that conforms to `FileStorageRepresentable`.
///
/// This class acts as an adapter, allowing dependency injection of any concrete type that conforms
/// to `FileStorageRepresentable`.
public final class FileStorage<T: Codable>: FileStorageRepresentable {

    /// A closure that handles the save operation for an object of type `T`.
    private let saveFunction: (T) async throws -> Void

    /// A closure that handles the load operation and returns an optional object of type `T`.
    private let loadFunction: () async throws -> T?

    /// A closure that handles the delete operation.
    private let deleteFunction: () async throws -> Void

    /// Initializes a `FileStorage` instance by wrapping an existing `FileStorageRepresentable`
    /// implementation.
    ///
    /// - Parameter storage: An instance of a type that conforms to `FileStorageRepresentable`.
    public init<U: FileStorageRepresentable>(_ storage: U) where U.T == T {
        self.saveFunction = storage.save
        self.loadFunction = storage.load
        self.deleteFunction = storage.delete
    }

    /// Saves an object to storage.
    ///
    /// - Parameter object: The object to be saved.
    /// - Throws: An error if the save operation fails.
    public func save(_ object: T) async throws {
        try await saveFunction(object)
    }

    /// Loads an object from storage.
    ///
    /// - Returns: The loaded object if it exists, otherwise `nil`.
    /// - Throws: An error if the load operation fails.
    public func load() async throws -> T? {
        try await loadFunction()
    }

    /// Deletes the stored object from storage.
    ///
    /// - Throws: An error if the delete operation fails.
    public func delete() async throws {
        try await deleteFunction()
    }
}
