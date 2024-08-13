//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol for asynchronous file storage operations, providing methods to save, load, delete,
/// and list objects in a storage system.
///
/// `FileStorageRepresentable` defines a set of operations for managing objects in persistent
/// storage. The objects being stored must conform to the `Codable` protocol, allowing them to be
/// serialized and deserialized for storage and retrieval. The protocol is marked as `Sendable` to
/// ensure thread safety when used in concurrent contexts, and it supports asynchronous operations
/// using `async` and `throws`.
///
/// - Note: This protocol is designed for use in systems that require persistent storage of
/// Codable objects, such as saving application data or caching results.
public protocol FileStorageRepresentable: Sendable {

    /// The type of object that this storage manages.
    ///
    /// The object type must conform to `Codable`, ensuring it can be serialized to and from a
    /// format suitable for file storage, such as JSON or Property List.
    associatedtype T: Codable

    /// Saves an object to storage under the specified file name.
    ///
    /// This method asynchronously saves the provided object to storage, associating it with the
    /// given file name. The object must conform to `Codable` to ensure it can be properly
    /// serialized and stored. If the save operation fails, an error is thrown.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Codable`.
    ///   - fileName: The name under which the object will be saved. This name is used to retrieve,
    ///     update, or delete the object in future operations.
    /// - Throws: An error if the save operation fails, such as due to write permissions,
    ///   serialization errors, or disk space issues.
    @Sendable func save(_ object: T, with fileName: String) async throws

    /// Loads an object from storage with the specified file name.
    ///
    /// This method asynchronously loads an object from storage using the provided file name. If
    /// the file does not exist or cannot be read, the method returns `nil`. The object must conform
    /// to `Codable` to ensure it can be properly deserialized. If the load operation fails, an
    /// error is thrown.
    ///
    /// - Parameter withName: The name of the file from which to load the object.
    /// - Returns: The loaded object, or `nil` if the object could not be found.
    /// - Throws: An error if the load operation fails, such as due to read permissions, file
    ///   corruption, or missing files.
    @Sendable func load(file withName: String) async throws -> T?

    /// Deletes an object from storage with the specified file name.
    ///
    /// This method asynchronously deletes the object associated with the given file name from
    /// storage. If the delete operation fails, an error is thrown. This is useful for removing
    /// outdated or no longer needed data.
    ///
    /// - Parameter withName: The name of the file to delete. This file name should match the name
    ///     used when the object was saved.
    /// - Throws: An error if the delete operation fails, such as due to file permissions, file
    ///   locks, or non-existent files.
    @Sendable func delete(file withName: String) async throws

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
    @Sendable func listAllIdentifiers() async throws -> [String]
}
