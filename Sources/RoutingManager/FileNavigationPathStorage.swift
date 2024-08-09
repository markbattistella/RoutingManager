//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An implementation of `NavigationPathStorage` that saves and loads navigation data using
/// the file system.
///
/// - Note: For performance-critical applications, consider performing file operations on a
/// background thread to avoid blocking the main thread.
public struct FileNavigationPathStorage: NavigationPathStorage {
    
    private let fileManager = FileManager.default
    
    /// Initializes a new instance of `FileNavigationPathStorage`.
    public init() {}
    
    /// Computes the file path for storing or retrieving navigation path data based on an identifier.
    ///
    /// - Parameter identifier: An optional identifier to customize the filename. If `nil`, a
    ///   default filename is used.
    /// - Returns: A URL representing the file path for the specified identifier.
    private func getFilePath(for identifier: String? = nil) -> URL {
        let fileName = identifier.map { "\($0)NavigationPath.json" } ?? "defaultNavigationPath.json"
        let documentDirectory = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    /// Saves data to the file system with encryption.
    ///
    /// - Parameters:
    ///   - data: The data to be saved.
    ///   - identifier: An optional identifier to customize the filename.
    /// - Throws: An error if the data could not be saved.
    public func save(data: Data, identifier: String?) throws {
        let path = getFilePath(for: identifier)
        do {
            try data.write(to: path, options: [.atomic, .completeFileProtection])
        } catch let error as NSError {
            switch error.code {
                case NSFileWriteNoPermissionError:
                    throw NavigationError.permissionDenied
                case NSFileNoSuchFileError:
                    throw NavigationError.fileNotFound
                default:
                    throw NavigationError.storageFailed(reason: error.localizedDescription)
            }
        }
    }
    
    /// Loads data from the file system with encryption support.
    ///
    /// - Parameter identifier: An optional identifier to customize the filename.
    /// - Returns: The data loaded from the file system.
    /// - Throws: An error if the data could not be loaded.
    public func load(identifier: String?) throws -> Data {
        let path = getFilePath(for: identifier)
        do {
            return try Data(contentsOf: path)
        } catch let error as NSError {
            switch error.code {
                case NSFileReadNoPermissionError:
                    throw NavigationError.permissionDenied
                case NSFileNoSuchFileError:
                    throw NavigationError.fileNotFound
                default:
                    throw NavigationError.storageFailed(reason: error.localizedDescription)
            }
        }
    }
}
