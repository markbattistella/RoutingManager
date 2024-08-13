//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing possible errors that can occur during navigation operations.
///
/// The `NavigationError` enum defines various error cases that may arise when managing navigation
/// paths, such as not finding a specified path, encountering file system issues, or failing to
/// save or load navigation data. Each case provides context about the error, often including
/// associated data to help diagnose the issue.
///
/// - Note: This enum is intended for use in navigation systems that involve storing, loading,
/// and managing navigation paths, particularly in applications that persist navigation state.
public enum NavigationError: Error {
    
    /// The specified navigation path was not found.
    ///
    /// This error occurs when an operation attempts to reference a navigation path that does not
    /// exist in the current context or storage.
    case pathNotFound
    
    /// The specified `PathIdentifier` was not found.
    ///
    /// This error occurs when a `PathIdentifier` cannot be found in the system, often due to
    /// missing or incorrectly specified identifiers during navigation operations.
    ///
    /// - Parameter identifier: The label or description of the path identifier that could not
    ///   be found. This provides additional context for debugging and user feedback.
    case pathIdentifierNotFound(String)
    
    /// A file system error occurred during an operation.
    ///
    /// This error indicates that an underlying file system issue occurred, such as a failure to
    /// read, write, or delete a file. The associated error provides more detailed information.
    ///
    /// - Parameter error: The underlying file system error that triggered this case. This is
    ///   useful for logging and diagnosing the specific file system issue encountered.
    case fileSystemError(Error)
    
    /// The navigation path could not be saved.
    ///
    /// This error occurs when an attempt to save the navigation path fails. The associated error
    /// provides more detailed information about the cause of the failure.
    ///
    /// - Parameter error: The underlying error that occurred during the save operation. This
    ///   helps in diagnosing issues such as write permissions, serialization errors, or disk
    ///   space issues.
    case saveError(Error)
    
    /// The navigation path could not be loaded.
    ///
    /// This error occurs when an attempt to load the navigation path fails. The associated error
    /// provides more detailed information about the cause of the failure.
    ///
    /// - Parameter error: The underlying error that occurred during the load operation. This
    ///   could be due to issues like file corruption, read permissions, or missing files.
    case loadError(Error)
    
    /// The navigation path could not be deleted.
    ///
    /// This error occurs when an attempt to delete a navigation path fails. The associated error
    /// provides more detailed information about the cause of the failure.
    ///
    /// - Parameter error: The underlying error that occurred during the delete operation. This
    ///   helps in identifying issues like file locks, permissions, or non-existent files.
    case deleteError(Error)
}

extension NavigationError: LocalizedError {
    
    /// A localized message describing what error occurred.
    ///
    /// This property provides a user-friendly description of the error, suitable for displaying
    /// in the UI or logging. The message varies depending on the error case, giving context to
    /// the user or developer about what went wrong.
    public var errorDescription: String? {
        switch self {
            case .pathNotFound:
                return "The specified navigation path was not found."
            case .pathIdentifierNotFound(let identifier):
                return "The specified path identifier was not found: \(identifier)."
            case .fileSystemError(let error):
                return "A file system error occurred: \(error.localizedDescription)."
            case .saveError(let error):
                return "Failed to save the navigation path: \(error.localizedDescription)."
            case .loadError(let error):
                return "Failed to load the navigation path: \(error.localizedDescription)."
            case .deleteError(let error):
                return "Failed to delete the navigation path: \(error.localizedDescription)."
        }
    }
}
