//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Represents the result of a navigation operation.
public enum NavigationResult {

    /// The result is unknown or has not been determined.
    case unknown

    /// The navigation operation was successful.
    case success

    /// The navigation operation failed with an associated error.
    case failure(NavigationError)

    /// Executes a handler function if the navigation result is a failure.
    ///
    /// - Parameter handler: A closure that receives the `NavigationError` if the result
    /// is `.failure`.
    /// - Returns: The same `NavigationResult` instance, allowing for method chaining.
    @discardableResult
    public func navigationError(
        _ handler: (NavigationError) -> Void
    ) -> NavigationResult {
        if case .failure(let error) = self { handler(error) }
        return self
    }
}
