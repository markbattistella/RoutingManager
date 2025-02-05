//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A lightweight, in-memory storage solution conforming to `FileStorageRepresentable`.
///
/// This class stores `Codable` objects in memory rather than persisting them to disk.
/// It is useful for temporary data storage during runtime.
///
/// - Note: Since this storage is memory-based, data is lost when the application terminates.
public final class MemoryStorage<T: Codable>: FileStorageRepresentable {

    /// The in-memory storage for the object.
    private var storage: T?

    /// Initializes an empty memory storage instance.
    public init() {}

    /// Saves an object in memory.
    ///
    /// - Parameter object: The `Codable` object to be stored.
    public func save(_ object: T) async throws { storage = object }

    /// Loads the stored object from memory.
    ///
    /// - Returns: The stored object if available, otherwise `nil`.
    public func load() async throws -> T? { return storage }

    /// Deletes the stored object from memory.
    public func delete() async throws { storage = nil }
}
