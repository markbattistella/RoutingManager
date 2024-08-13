//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol for managing navigation routes in a SwiftUI application.
///
/// `NavigationRouteDelegate` defines a set of methods for managing a navigation stack, including
/// pushing new routes, navigating back, and replacing routes. It provides a structured way to
/// handle navigation actions, ensuring consistency and type safety in applications that use
/// SwiftUI for navigation.
///
/// - Note: This protocol is intended for internal use within navigation management systems and is
/// marked as `internal` to restrict its visibility outside the module. It is also marked with
/// `@MainActor` to ensure that all navigation operations occur on the main thread, which is
/// necessary for UI updates.
@MainActor
internal protocol NavigationRouteDelegate {

    /// The type of route that this delegate will manage.
    ///
    /// This associated type must conform to the `NavigationRouteRepresentable` protocol, ensuring
    /// that all routes managed by this delegate are uniquely identifiable and can be rendered as
    /// SwiftUI views.
    associatedtype Route = NavigationRouteRepresentable

    /// Pushes one or more routes onto the navigation stack.
    ///
    /// This method adds the specified routes to the navigation stack, effectively navigating to
    /// the new screens. The routes are pushed in the order they are provided. An optional
    /// `PathIdentifier` can be supplied to associate the navigation action with a specific path.
    ///
    /// - Parameters:
    ///   - screens: The screens (routes) to push onto the stack. These routes must conform to
    ///     `NavigationRouteRepresentable`.
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the push operation, indicating whether it was successful or if
    ///   an error occurred.
    @discardableResult
    func push(to screens: Route..., for identifier: PathIdentifier?) -> NavigationResult

    /// Navigates back by removing a specified number of screens from the navigation stack.
    ///
    /// This method removes the specified number of screens from the top of the navigation stack,
    /// effectively navigating back by the given number of steps. If the number of screens to
    /// remove exceeds the number of screens currently in the stack, the stack will be emptied.
    /// An optional `PathIdentifier` can be supplied to associate the navigation action with a
    /// specific path.
    ///
    /// - Parameters:
    ///   - numberOfScreens: The number of screens to remove from the stack. Defaults to 1.
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the back navigation operation, indicating whether it was
    ///   successful or if an error occurred.
    @discardableResult
    func goBack(_ numberOfScreens: Int, for identifier: PathIdentifier?) -> NavigationResult

    /// Navigates to the first occurrence of a specific route in the navigation stack.
    ///
    /// This method searches the navigation stack for the first occurrence of the specified route
    /// and navigates to it, removing any screens above it in the stack. If the route is not found,
    /// the method returns a failure result. An optional `PathIdentifier` can be supplied to
    /// associate the navigation action with a specific path.
    ///
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to. This route must conform to
    ///     `NavigationRouteRepresentable`.
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the navigation operation, indicating whether it was successful or
    ///   if an error occurred.
    @discardableResult
    func goToFirstOccurrence(of screen: Route, for identifier: PathIdentifier?) -> NavigationResult

    /// Navigates to the last occurrence of a specific route in the navigation stack.
    ///
    /// This method searches the navigation stack for the last occurrence of the specified route
    /// and navigates to it, removing any screens above it in the stack. If the route is not found,
    /// the method returns a failure result. An optional `PathIdentifier` can be supplied to
    /// associate the navigation action with a specific path.
    ///
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to. This route must conform to
    ///     `NavigationRouteRepresentable`.
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the navigation operation, indicating whether it was successful or
    ///   if an error occurred.
    @discardableResult
    func goToLastOccurrence(of screen: Route, for identifier: PathIdentifier?) -> NavigationResult

    /// Replaces the current route in the navigation stack with a new route.
    ///
    /// This method replaces the current top route in the navigation stack with the specified
    /// route. This is useful for scenarios where you want to replace the current screen without
    /// navigating back first. An optional `PathIdentifier` can be supplied to associate the
    /// navigation action with a specific path.
    ///
    /// - Parameters:
    ///   - screen: The new screen (route) to replace the current route with. This route must
    ///     conform to `NavigationRouteRepresentable`.
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the replacement operation, indicating whether it was successful
    ///   or if an error occurred.
    @discardableResult
    func replaceCurrent(with screen: Route, for identifier: PathIdentifier?) -> NavigationResult

    /// Replaces the entire current navigation stack with a new set of routes.
    ///
    /// This method clears the current navigation stack and replaces it with the specified set of
    /// routes. This is useful for scenarios where you want to reset the navigation history and
    /// start fresh with a new set of screens. An optional `PathIdentifier` can be supplied to
    /// associate the navigation action with a specific path.
    ///
    /// - Parameters:
    ///   - routes: The new set of routes to replace the current stack. These routes must conform
    ///     to `NavigationRouteRepresentable`.
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the stack replacement operation, indicating whether it was
    ///   successful or if an error occurred.
    @discardableResult
    func replaceCurrentStack(with routes: [Route], for identifier: PathIdentifier?) -> NavigationResult

    /// Resets the navigation stack to an empty state.
    ///
    /// This method clears all routes from the navigation stack, effectively resetting the
    /// navigation history. An optional `PathIdentifier` can be supplied to associate the
    /// navigation action with a specific path.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier associated with this navigation action.
    ///     Defaults to `nil`, meaning no specific path is associated.
    /// - Returns: The result of the reset operation, indicating whether it was successful or if
    ///   an error occurred.
    @discardableResult
    func resetNavigation(for identifier: PathIdentifier?) -> NavigationResult
}
