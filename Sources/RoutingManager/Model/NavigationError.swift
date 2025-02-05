//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Represents errors that can occur during navigation-related operations.
public enum NavigationError: Error {

    /// The specified navigation path was not found.
    case pathNotFound

    /// An error occurred while attempting to save the navigation state.
    ///
    /// - Parameter error: The underlying error that caused the save operation to fail.
    case save(Error)

    /// An error occurred while attempting to load a saved navigation state.
    ///
    /// - Parameter error: The underlying error that caused the load operation to fail.
    case load(Error)

    /// An error occurred while attempting to delete a stored navigation state.
    ///
    /// - Parameter error: The underlying error that caused the delete operation to fail.
    case delete(Error)
}

extension NavigationError: LocalizedError {

    /// Provides a human-readable description of the error.
    public var errorDescription: String? {
        switch self {
            case .pathNotFound:
                return "Path not found."
            case .save(let error):
                return "Save failed: \(error.localizedDescription)"
            case .load(let error):
                return "Load failed: \(error.localizedDescription)"
            case .delete(let error):
                return "Delete failed: \(error.localizedDescription)"
        }
    }
}
