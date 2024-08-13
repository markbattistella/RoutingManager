//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing the result of a navigation operation.
///
/// `NavigationResult` is used to indicate whether a navigation operation was successful or if it
/// failed with a specific error. This enum can be used to handle the outcome of navigation
/// actions in a SwiftUI application, providing a clear and consistent way to manage success and
/// error states.
///
/// - Note: This enum is designed for use in navigation systems where operations may succeed or
/// fail, and where error handling is necessary.
public enum NavigationResult: Sendable {
    
    /// The operation was successful.
    ///
    /// This case indicates that the navigation operation completed successfully without any errors.
    case success
    
    /// The operation failed with a specific error.
    ///
    /// This case indicates that the navigation operation failed. The associated `NavigationError`
    /// provides detailed information about what went wrong during the operation.
    ///
    /// - Parameter error: The `NavigationError` that occurred during the operation, providing
    ///   context for the failure.
    case failure(NavigationError)
    
    /// Executes a handler if the result is a failure, passing the error to the handler.
    ///
    /// This method allows you to easily handle errors in a fluent, chainable way. If the result
    /// is a failure, the provided `handler` closure is called with the associated `NavigationError`.
    /// This is useful for performing additional error handling or logging within a chain of method
    /// calls.
    ///
    /// - Parameter handler: A closure that handles the `NavigationError` if the result is a failure.
    /// - Returns: The `NavigationResult` itself, allowing for fluent chaining of additional
    ///   operations.
    ///
    /// - Note: The result of this method can be discarded if you don't need to handle the outcome.
    ///   This allows for more flexible use in cases where error handling is optional.
    @discardableResult
    public func navigationError(_ handler: (NavigationError) -> Void) -> NavigationResult {
        if case .failure(let error) = self { handler(error) }
        return self
    }
}
