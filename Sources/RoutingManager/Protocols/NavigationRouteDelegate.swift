//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol that defines the required methods for managing navigation actions,
/// such as pushing, popping, and replacing routes within a navigation stack.
///
/// This protocol is intended to be implemented by classes or structs that handle
/// navigation transitions, route management, and stack manipulation for routes
/// conforming to the `NavigationRouteRepresentable` protocol. The protocol is internal,
/// meaning it's only accessible within the module in which it's defined.
@MainActor
internal protocol NavigationRouteDelegate: Sendable {

    /// The type of route that this delegate will manage. It must conform to the
    /// `NavigationRouteRepresentable` protocol.
    associatedtype Route = NavigationRouteRepresentable

    /// Pushes one or more routes onto the navigation stack.
    ///
    /// - Parameters:
    ///   - screens: The screens (routes) to push onto the stack.
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the push operation, indicating success or failure.
    @discardableResult
    func push(to screens: Route..., for identifier: PathIdentifier?) -> NavigationResult

    /// Navigates back by removing a specified number of screens from the navigation stack.
    ///
    /// - Parameters:
    ///   - numberOfScreens: The number of screens to remove from the stack.
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the back navigation operation, indicating success or failure.
    @discardableResult
    func goBack(_ numberOfScreens: Int, for identifier: PathIdentifier?) -> NavigationResult

    /// Navigates to the first occurrence of a specific route in the navigation stack.
    ///
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to.
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    func goToFirstOccurrence(of screen: Route, for identifier: PathIdentifier?) -> NavigationResult

    /// Navigates to the last occurrence of a specific route in the navigation stack.
    ///
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to.
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    func goToLastOccurrence(of screen: Route, for identifier: PathIdentifier?) -> NavigationResult

    /// Replaces the current route in the navigation stack with a new route.
    ///
    /// - Parameters:
    ///   - screen: The new screen (route) to replace the current route with.
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the replacement operation, indicating success or failure.
    @discardableResult
    func replaceCurrent(with screen: Route, for identifier: PathIdentifier?) -> NavigationResult

    /// Replaces the entire current navigation stack with a new set of routes.
    ///
    /// - Parameters:
    ///   - routes: The new set of routes to replace the current stack.
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the stack replacement operation, indicating success or failure.
    @discardableResult
    func replaceCurrentStack(with routes: [Route], for identifier: PathIdentifier?) -> NavigationResult

    /// Resets the navigation stack to an empty state.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier associated with this navigation action,
    ///   defaults to `nil`.
    /// - Returns: The result of the reset operation, indicating success or failure.
    @discardableResult
    func resetNavigation(for identifier: PathIdentifier?) -> NavigationResult
}
