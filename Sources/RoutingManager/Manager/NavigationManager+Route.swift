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
        return performSaveOperation(
            "Pushing \(screens.count) screen(s) onto navigation stack '\(stack.id)'."
        )
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
        return performSaveOperation(
            "Going back \(removedScreens) screen(s) in navigation stack '\(stack.id)'."
        )
    }

    /// Navigates to a specific occurrence of a screen in the navigation stack.
    ///
    /// - Parameters:
    ///   - screen: The screen to navigate to.
    ///   - direction: The direction to search for the occurrence (`first` or `last`).
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func goToOccurrence(of screen: Route, direction: OccurrenceDirection) -> NavigationResult
    {
        guard let routes = navigationState[stack], !routes.isEmpty else {
            logger.warning(
                "Navigation stack '\(self.stack.id)' is empty. Cannot find screen '\(screen.id)'."
            )
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
        return performSaveOperation(
            "Navigating to \(direction.rawValue) occurrence of screen '\(screen.id)' at index \(index) in stack '\(stack.id)'."
        )
    }

    /// Replaces the current screen with a new screen.
    ///
    /// - Parameter screen: The screen to replace the current screen with.
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func replaceCurrentScreen(with screen: Route) -> NavigationResult {
        guard var routes = navigationState[stack], !routes.isEmpty else {
            logger.warning(
                "Navigation stack '\(self.stack.id)' is empty. Cannot replace the current screen."
            )
            return .failure(.pathNotFound)
        }
        let previousScreen = routes.last
        routes.removeLast()
        routes.append(screen)
        navigationState[stack] = routes
        return performSaveOperation(
            "Replaced screen '\(previousScreen?.id ?? "unknown")' with '\(screen.id)' in navigation stack '\(self.stack.id)'."
        )
    }

    /// Replaces the entire navigation stack with a new sequence of screens.
    ///
    /// - Parameter routes: The new stack of screens to replace the current stack.
    /// - Returns: A `NavigationResult` indicating success or failure of the operation.
    @discardableResult
    public func replaceCurrentStack(with routes: Route...) -> NavigationResult {
        navigationState[stack] = routes
        return performSaveOperation(
            "Replacing entire navigation stack '\(self.stack.id)' with \(routes.count) new route(s)."
        )
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
