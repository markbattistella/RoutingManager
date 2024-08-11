//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration that represents the outcome of a navigation operation.
///
/// `NavigationResult` indicates whether a navigation operation was successful or if it failed
/// with a specific `NavigationError`. It includes a method for handling errors in a fluent style.
///
/// - Note: This enum provides a simple way to manage the success or failure of navigation-related
/// operations.
public enum NavigationResult: Sendable {
    
    /// The operation was successful.
    case success
    
    /// The operation failed with a specific error.
    ///
    /// - Parameter error: The `NavigationError` that occurred during the operation.
    case failure(NavigationError)
    
    /// Executes a handler if the result is a failure, passing the error to the handler.
    ///
    /// - Parameter handler: A closure that handles the `NavigationError` if the result is a failure.
    /// - Returns: The `NavigationResult` itself, allowing for fluent chaining.
    ///
    /// - Note: The result of this method can be discarded if you don't need to handle the outcome.
    @discardableResult
    public func navigationError(_ handler: (NavigationError) -> Void) -> NavigationResult {
        if case .failure(let error) = self {
            handler(error)
        }
        return self
    }
}
