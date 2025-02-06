//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing possible navigation-related errors.
///
/// `NavigationError` provides error cases for handling failures in navigation operations,
/// such as missing paths or failures during save, load, and delete operations.
public enum NavigationError: Error {

    /// Error indicating that the requested navigation path was not found.
    case pathNotFound

    /// Error indicating a failure when attempting to save the navigation state.
    ///
    /// - Parameter error: The underlying error that caused the failure.
    case save(Error)

    /// Error indicating a failure when attempting to load a saved navigation state.
    ///
    /// - Parameter error: The underlying error that caused the failure.
    case load(Error)

    /// Error indicating a failure when attempting to delete a saved navigation state.
    ///
    /// - Parameter error: The underlying error that caused the failure.
    case delete(Error)
}

extension NavigationError: LocalizedError {

    /// Provides a localized description of the error.
    public var errorDescription: String? {
        switch self {
            /// Returns a message indicating that the navigation path was not found.
            case .pathNotFound:
                return "Path not found."

            /// Returns a message indicating a save failure with the underlying error description.
            case .save(let error):
                return "Save failed: \(error.localizedDescription)"

            /// Returns a message indicating a load failure with the underlying error description.
            case .load(let error):
                return "Load failed: \(error.localizedDescription)"

            /// Returns a message indicating a delete failure with the underlying error description.
            case .delete(let error):
                return "Delete failed: \(error.localizedDescription)"
        }
    }
}
