//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol defining navigation operations for managing a navigation stack.
///
/// The `NavigationRouteDelegate` protocol provides methods to manipulate navigation stacks,
/// including pushing screens, navigating back, replacing screens, and resetting the navigation flow.
internal protocol NavigationRouteDeletgate {

    /// The type that represents the navigation stack.
    associatedtype Stack: NavigationStackRepresentable

    /// The type that represents individual navigation routes.
    associatedtype Route: NavigationRouteRepresentable

    /// Pushes one or more screens onto the navigation stack.
    ///
    /// - Parameter screens: The screens to be pushed onto the stack.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func push(to screens: Route...) -> NavigationResult

    /// Navigates back by a specified number of screens.
    ///
    /// - Parameter numberOfScreens: The number of screens to navigate back.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func goBack(_ numberOfScreens: Int) -> NavigationResult

    /// Navigates to a specific occurrence of a screen in the navigation stack.
    ///
    /// - Parameters:
    ///   - screen: The screen to navigate to.
    ///   - direction: The direction to search for the occurrence (e.g., forward or backward).
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func goToOccurrence(of screen: Route, direction: OccurrenceDirection) -> NavigationResult

    /// Replaces the current screen with a new screen.
    ///
    /// - Parameter screen: The screen to replace the current screen with.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func replaceCurrentScreen(with screen: Route) -> NavigationResult

    /// Replaces the selected navigation stack with a new sequence of screens.
    ///
    /// - Parameters:
    ///   - stack: The stack to replace with the new screens.
    ///   - routes: The new stack of screens to replace with.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Note: `routes` is an array opposed to variadic array since there is no Swift splatting
    /// method at present.
    @discardableResult
    func replace(stack: Stack, with routes: [Route]) -> NavigationResult

    /// Overrides the entire stored stack with a new set of stacks and routes.
    ///
    /// - Parameter navigation: The new stack and routes to replace with.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func override(navigation: [Stack: [Route]]) -> NavigationResult

    /// Resets the navigation stack, removing all screens and starting fresh.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func resetNavigation() -> NavigationResult
}
