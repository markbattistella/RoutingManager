//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

extension NavigationManager: NavigationRouteDeletgate {

    /// Pushes one or more screens onto the navigation stack.
    ///
    /// - Parameter screens: The route(s) representing the screen(s) to be pushed.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func push(
        to screens: Route...
    ) async throws -> NavigationResult {
        navigationState[stack, default: []].append(contentsOf: screens)
        return await performSaveOperation(
            "Pushing \(screens.count) screen(s) onto navigation stack '\(stack.id)'."
        )
    }

    /// Navigates back by a specified number of screens.
    ///
    /// - Parameter numberOfScreens: The number of screens to go back.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func goBack(
        _ numberOfScreens: Int
    ) async throws -> NavigationResult {
        guard let routes = navigationState[stack], !routes.isEmpty else {
            logger.warning(
                "Cannot go back. Navigation stack '\(self.stack.id)' is already empty."
            )
            return .failure(.pathNotFound)
        }
        let removedScreens = min(numberOfScreens, routes.count)
        navigationState[stack]?.removeLast(removedScreens)
        return await performSaveOperation(
            "Going back \(removedScreens) screen(s) in navigation stack '\(stack.id)'."
        )
    }

    /// Navigates to the first or last occurrence of a specific screen within the stack.
    ///
    /// - Parameters:
    ///   - screen: The route representing the screen to find.
    ///   - direction: The direction in which to search for the occurrence.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func goToOccurrence(
        of screen: Route,
        direction: OccurrenceDirection
    ) async throws -> NavigationResult {
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
        return await performSaveOperation(
            "Navigating to \(direction.rawValue) occurrence of screen '\(screen.id)' at index \(index) in stack '\(stack.id)'."
        )
    }

    /// Replaces the current screen with a new screen.
    ///
    /// - Parameter screen: The route representing the new screen to replace the current one.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func replaceCurrentScreen(
        with screen: Route
    ) async throws -> NavigationResult {
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
        return await performSaveOperation(
            "Replaced screen '\(previousScreen?.id ?? "unknown")' with '\(screen.id)' in navigation stack '\(self.stack.id)'."
        )
    }

    /// Replaces the entire current navigation stack with a new set of screens.
    ///
    /// - Parameter routes: The routes representing the new stack.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func replaceCurrentStack(
        with routes: Route...
    ) async throws -> NavigationResult {
        navigationState[stack] = routes
        return await performSaveOperation(
            "Replacing entire navigation stack '\(self.stack.id)' with \(routes.count) new route(s)."
        )
    }

    /// Resets the navigation stack, clearing all existing routes.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func resetNavigation() async throws -> NavigationResult {
        navigationState[stack] = []
        return await performSaveOperation(
            "Resetting navigation stack '\(self.stack.id)'."
        )
    }
}
