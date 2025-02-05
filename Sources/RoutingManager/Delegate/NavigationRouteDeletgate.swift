//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A delegate protocol responsible for handling navigation actions within a navigation stack.
internal protocol NavigationRouteDeletgate {

    /// The type representing the navigation stack.
    associatedtype Stack: NavigationStackRepresentable

    /// The type representing a navigable route.
    associatedtype Route: NavigationRouteRepresentable

    /// Pushes one or more screens onto the navigation stack.
    ///
    /// - Parameter screens: The route(s) representing the screen(s) to be pushed.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the push operation fails.
    @discardableResult
    func push(
        to screens: Route...
    ) async throws -> NavigationResult

    /// Navigates back by a specified number of screens.
    ///
    /// - Parameter numberOfScreens: The number of screens to go back.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the operation fails.
    @discardableResult
    func goBack(
        _ numberOfScreens: Int
    ) async throws -> NavigationResult

    /// Navigates to the first or last occurrence of a specific screen within the stack.
    ///
    /// - Parameters:
    ///   - screen: The route representing the screen to find.
    ///   - direction: The direction in which to search for the occurrence.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the operation fails.
    @discardableResult
    func goToOccurrence(
        of screen: Route,
        direction: OccurrenceDirection
    ) async throws -> NavigationResult

    /// Replaces the current screen with a new screen.
    ///
    /// - Parameter screen: The route representing the new screen to replace the current one.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the replacement operation fails.
    @discardableResult
    func replaceCurrentScreen(
        with screen: Route
    ) async throws -> NavigationResult

    /// Replaces the entire current navigation stack with a new set of screens.
    ///
    /// - Parameter routes: The routes representing the new stack.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the operation fails.
    @discardableResult
    func replaceCurrentStack(
        with routes: Route...
    ) async throws -> NavigationResult

    /// Resets the navigation stack, clearing all existing routes.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the reset operation fails.
    @discardableResult
    func resetNavigation() async throws -> NavigationResult
}
