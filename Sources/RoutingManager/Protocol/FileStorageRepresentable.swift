//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol that defines methods for saving, loading, and deleting objects in file storage.
public protocol FileStorageRepresentable {

    /// The type of object that can be stored, which must conform to `Codable`.
    associatedtype T: Codable

    /// Saves an object to file storage.
    ///
    /// - Parameter object: The object to be saved.
    /// - Throws: An error if the save operation fails.
    func save(_ object: T) async throws

    /// Loads an object from file storage.
    ///
    /// - Returns: The loaded object if it exists, otherwise `nil`.
    /// - Throws: An error if the load operation fails.
    func load() async throws -> T?

    /// Deletes the stored object from file storage.
    ///
    /// - Throws: An error if the delete operation fails.
    func delete() async throws
}
