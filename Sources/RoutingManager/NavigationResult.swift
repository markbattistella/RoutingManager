//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enum that represents the result of a navigation operation.
public enum NavigationResult: Equatable {
    case success
    case failure(NavigationError)
    
    /// Handles the error of a navigation operation using the provided closure, if an error exists.
    ///
    /// - Parameter handler: A closure that takes a `NavigationError` as its argument.
    /// - Returns: The same `NavigationResult` instance, allowing for method chaining.
    ///
    /// - Note: This method is marked with `@discardableResult`, meaning the return value can
    ///   be ignored if chaining is not needed.
    ///
    /// - Example:
    /// ```swift
    /// routeManager.push(to: .details)
    ///     .navigationError { error in
    ///         print("Error occurred: \(error.localizedDescription)")
    ///     }
    /// ```
    @discardableResult
    public func navigationError(_ handler: (NavigationError) -> Void) -> NavigationResult {
        if case .failure(let error) = self {
            handler(error)
        }
        return self
    }

    // Conformance to Equatable for testing purposes
    public static func == (lhs: NavigationResult, rhs: NavigationResult) -> Bool {
        switch (lhs, rhs) {
            case (.success, .success):
                return true
            case (.failure(let lhsError), .failure(let rhsError)):
                return lhsError == rhsError
            default:
                return false
        }
    }
}
