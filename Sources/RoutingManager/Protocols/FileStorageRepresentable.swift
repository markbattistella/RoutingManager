//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol that defines the basic operations for a storage system that handles objects 
/// conforming to `Codable`.
///
/// Types conforming to `FileStorageRepresentable` provide mechanisms to save, load, delete,
/// and list stored objects. The objects being managed must conform to `Codable`.
///
/// - Note: This protocol uses an associated type `T` to represent the type of object
///   being stored.
public protocol FileStorageRepresentable {
    
    associatedtype T: Codable
    
    /// Saves an object to storage under the specified file name.
    ///
    /// - Parameters:
    ///   - object: The object to save. This object must conform to `Codable`.
    ///   - fileName: The name under which the object will be saved.
    /// - Throws: An error if the save operation fails.
    func save(_ object: T, with fileName: String) async throws
    
    /// Loads an object from storage with the specified file name.
    ///
    /// - Parameter withName: The name of the file from which to load the object.
    /// - Returns: The loaded object, or `nil` if the object could not be found.
    /// - Throws: An error if the load operation fails.
    func load(file withName: String) async throws -> T?
    
    /// Deletes an object from storage with the specified file name.
    ///
    /// - Parameter withName: The name of the file to delete.
    /// - Throws: An error if the delete operation fails.
    func delete(file withName: String) async throws
    
    /// Lists all identifiers (file names) of objects currently stored.
    ///
    /// - Returns: An array of strings representing the identifiers of all stored objects.
    /// - Throws: An error if the list operation fails.
    func listAllIdentifiers() async throws -> [String]
}
