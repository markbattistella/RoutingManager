//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing the result of a navigation operation.
///
/// `NavigationResult` provides cases for successful, failed, and unknown navigation outcomes.
public enum NavigationResult {

    /// The navigation result is unknown.
    case unknown

    /// The navigation operation was successful.
    case success

    /// The navigation operation failed with an associated error.
    ///
    /// - Parameter error: The `NavigationError` describing the reason for the failure.
    case failure(NavigationError)

    /// Handles a navigation error if the result is a failure.
    ///
    /// This method allows error handling using a closure. If the result is `.failure`,
    /// the provided closure is executed with the associated `NavigationError`.
    ///
    /// - Parameter handler: A closure that receives the `NavigationError` when a failure occurs.
    /// - Returns: The current `NavigationResult` instance, allowing for method chaining.
    @discardableResult
    public func navigationError(
        _ handler: (NavigationError) -> Void
    ) -> NavigationResult {
        if case .failure(let error) = self { handler(error) }
        return self
    }
}
