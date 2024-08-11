//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing possible errors that can occur during navigation management
/// operations.
///
/// The `NavigationError` enum defines various error cases that may be encountered when working with
/// navigation paths, such as loading, saving, or deleting paths. Each error case provides a description
/// that is user-friendly and suitable for displaying in the UI or logging.
///
/// - Note: This enum conforms to both `Error` and `LocalizedError`, allowing it to be used
///   in error handling contexts with user-friendly error messages.
public enum NavigationError: Error, LocalizedError {

    /// The specified navigation path was not found.
    ///
    /// This error is returned when a requested navigation path does not exist or cannot be located.
    case pathNotFound

    /// The specified `PathIdentifier` was not found.
    ///
    /// This error occurs when the requested path identifier is not found in the storage or the current
    /// context.
    ///
    /// - Parameter identifier: The label or description of the path identifier that could not be found.
    case pathIdentifierNotFound(String)

    /// A file system error occurred during an operation.
    ///
    /// This error is used when there is an issue related to the file system, such as inability to read
    /// from or write to a file.
    ///
    /// - Parameter error: The underlying file system error.
    case fileSystemError(Error)

    /// The navigation path could not be saved.
    ///
    /// This error is returned when a failure occurs while attempting to save a navigation path to
    /// persistent storage.
    ///
    /// - Parameter error: The underlying error that occurred during the save operation.
    case saveError(Error)

    /// The navigation path could not be loaded.
    ///
    /// This error occurs when an attempt to load a navigation path from persistent storage fails.
    ///
    /// - Parameter error: The underlying error that occurred during the load operation.
    case loadError(Error)

    /// The navigation path could not be deleted.
    ///
    /// This error is returned when an attempt to delete a navigation path from persistent storage fails.
    ///
    /// - Parameter error: The underlying error that occurred during the delete operation.
    case deleteError(Error)

    /// An unknown error occurred.
    ///
    /// This error is a catch-all for situations where an error occurs, but it doesn't match any of the
    /// other specific cases.
    case unknownError

    /// A localized message describing what error occurred.
    ///
    /// This property provides a user-friendly description of the error, suitable for displaying
    /// in the UI or logging. The message varies depending on the error case.
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
            case .unknownError:
                return "An unknown error occurred."
        }
    }
}
