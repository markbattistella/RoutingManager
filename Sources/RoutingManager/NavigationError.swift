//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing errors that can occur during navigation operations.
public enum NavigationError: Error {

    /// Indicates that the specified route could not be found.
    case routeNotFound

    /// Indicates that the provided route is invalid.
    case invalidRoute

    /// Indicates that a failure occurred while attempting to save or load the navigation path.
    case storageFailed(reason: String)

    /// Indicates the saved path JSON file was not found.
    case fileNotFound

    /// Indicates reading or writing to the file system was denied.
    case permissionDenied

    /// Indicates that an unknown error occurred.
    case unknown
}

// MARK: - Localized descriptions

extension NavigationError {

    /// A human-readable description of the error.
    var localizedDescription: String {
        switch self {
            case .routeNotFound:
                return "The specified route could not be found."

            case .invalidRoute:
                return "The route provided is invalid."

            case .storageFailed(let reason):
                return "Failed to save or load the navigation path: \(reason)"

            case .fileNotFound:
                return "The requested file was not found."

            case .permissionDenied:
                return "Permission denied while accessing the file system."

            case .unknown:
                return "An unknown error occurred."
        }
    }
}

// MARK: - Equatable

extension NavigationError: Equatable {

    // Conformance to Equatable for testing purposes
    public static func == (lhs: NavigationError, rhs: NavigationError) -> Bool {
        switch (lhs, rhs) {
            case (.routeNotFound, .routeNotFound),
                (.invalidRoute, .invalidRoute),
                (.fileNotFound, .fileNotFound),
                (.permissionDenied, .permissionDenied),
                (.unknown, .unknown):
                return true
            case (.storageFailed(let lhsReason), .storageFailed(let rhsReason)):
                return lhsReason == rhsReason
            default:
                return false
        }
    }
}
