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

    /// Replaces the entire navigation stack with a new sequence of screens.
    ///
    /// - Parameter routes: The new stack of screens to replace the current stack.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func replaceCurrentStack(with routes: Route...) -> NavigationResult

    /// Resets the navigation stack, removing all screens and starting fresh.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func resetNavigation() -> NavigationResult
}
