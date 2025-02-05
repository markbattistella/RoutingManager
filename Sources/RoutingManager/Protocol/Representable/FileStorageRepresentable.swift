//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol defining file storage operations for saving, loading, and deleting data.
///
/// `FileStorageRepresentable` is designed to work with Codable data types, allowing objects to
/// be persisted to and retrieved from storage.
public protocol FileStorageRepresentable {

    /// The type of object that will be stored and must conform to `Codable`.
    associatedtype T: Codable

    /// Saves an object to storage.
    ///
    /// - Parameter object: The object to be saved.
    /// - Throws: An error if the save operation fails.
    func save(_ object: T) throws

    /// Loads an object from storage.
    ///
    /// - Returns: The loaded object if available, otherwise `nil`.
    /// - Throws: An error if the load operation fails.
    func load() throws -> T?

    /// Deletes the stored object from storage.
    ///
    /// - Throws: An error if the delete operation fails.
    func delete() throws
}
