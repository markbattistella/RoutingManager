//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

extension NavigationManager: NavigationRouteDeletgate {

    /// Pushes one or more screens onto the navigation stack.
    ///
    /// - Parameter screens: The screens to be pushed onto the stack.
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func push(to screens: Route...) -> NavigationResult {
        navigationState[stack, default: []].append(contentsOf: screens)
        return performSaveOperation("Pushing \(screens.count) screen(s) onto navigation stack '\(stack.id)'.")
    }

    /// Navigates back by a specified number of screens.
    ///
    /// - Parameter numberOfScreens: The number of screens to navigate back.
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func goBack(_ numberOfScreens: Int) -> NavigationResult {
        guard let routes = navigationState[stack], !routes.isEmpty else {
            logger.warning("Cannot go back. Navigation stack '\(self.stack.id)' is already empty.")
            return .failure(.pathNotFound)
        }
        let removedScreens = min(numberOfScreens, routes.count)
        navigationState[stack]?.removeLast(removedScreens)
        return performSaveOperation("Going back \(removedScreens) screen(s) in navigation stack '\(stack.id)'.")
    }

    /// Navigates to a specific occurrence of a screen in the navigation stack.
    ///
    /// - Parameters:
    ///   - screen: The screen to navigate to.
    ///   - direction: The direction to search for the occurrence (`first` or `last`).
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func goToOccurrence(of screen: Route, direction: OccurrenceDirection) -> NavigationResult {
        guard let routes = navigationState[stack], !routes.isEmpty else {
            logger.warning("Navigation stack '\(self.stack.id)' is empty. Cannot find screen '\(screen.id)'.")
            return .failure(.pathNotFound)
        }

        let index =
            (direction == .first)
            ? routes.firstIndex(where: { $0.id == screen.id })
            : routes.lastIndex(where: { $0.id == screen.id })

        guard let index = index else {
            logger.warning("Screen '\(screen.id)' not found in stack '\(self.stack.id)'.")
            return .failure(.pathNotFound)
        }

        navigationState[stack] = Array(routes.prefix(index + 1))
        return performSaveOperation("Navigating to \(direction.rawValue) occurrence of screen '\(screen.id)' at index \(index) in stack '\(stack.id)'.")
    }

    /// Replaces the current screen with a new screen.
    ///
    /// - Parameter screen: The screen to replace the current screen with.
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func replaceCurrentScreen(with screen: Route) -> NavigationResult {
        guard var routes = navigationState[stack], !routes.isEmpty else {
            logger.warning("Navigation stack '\(self.stack.id)' is empty. Cannot replace the current screen.")
            return .failure(.pathNotFound)
        }
        let previousScreen = routes.last
        routes.removeLast()
        routes.append(screen)
        navigationState[stack] = routes
        return performSaveOperation("Replaced screen '\(previousScreen?.id ?? "unknown")' with '\(screen.id)' in navigation stack '\(self.stack.id)'.")
    }

    /// Replaces the specified navigation stack with a new sequence of routes.
    ///
    /// This method updates a single stack while keeping the other stacks unchanged. It is useful
    /// when you need to modify a specific navigation stack without affecting the global navigation
    /// state.
    ///
    /// - Parameters:
    ///   - stack: The navigation stack to replace.
    ///   - routes: The new sequence of routes to be set in the specified stack.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func replace(stack: Stack, with routes: [Route]) -> NavigationResult {
        navigationState[stack] = routes
        return performSaveOperation("Replacing entire navigation stack '\(stack.id)' with \(routes.count) new route(s).")
    }

    /// Replaces the current stack associated with this navigation manager with a new sequence of
    /// routes.
    ///
    /// This method is a convenience function that replaces the navigation stack that the manager
    /// was initialized with, without requiring explicit reference to the stack itself.
    ///
    /// - Parameter routes: The new sequence of routes to replace the current stack.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func replaceCurrentStack(with routes: [Route]) -> NavigationResult {
        return replace(stack: stack, with: routes)
    }

    /// Overrides the entire navigation state with a new set of stacks and routes.
    ///
    /// This method completely replaces all existing navigation stacks and their associated routes
    /// with the provided navigation state. It is useful for resetting the navigation state entirely
    /// based on external events such as a remote push notification or a scheduled update.
    ///
    /// - Parameter navigation: A dictionary representing the new navigation state, where keys are
    /// stacks and values are arrays of routes.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    @discardableResult
    func override(navigation: [Stack: [Route]]) -> NavigationResult {
        navigationState = navigation
        return performSaveOperation("Overrode navigation state with new navigation data.")
    }

    /// Resets the navigation stack, removing all screens.
    ///
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func resetNavigation() -> NavigationResult {
        navigationState[stack] = []
        return performSaveOperation("Resetting navigation stack '\(self.stack.id)'.")
    }
}
