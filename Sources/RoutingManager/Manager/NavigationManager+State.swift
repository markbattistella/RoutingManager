//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

extension NavigationManager: NavigationStateDelegate {

    /// Lists all routes currently stored within the navigation state, organized by stack.
    ///
    /// - Returns: A dictionary mapping each stack to its corresponding list of routes.
    @discardableResult
    public func listRoutes() -> [Stack: [Route]] {
        logger.info(
            "Listing all routes in the navigation state."
        )
        return navigationState
    }

    /// Saves the current navigation state persistently.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the save operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    public func save() async throws -> NavigationResult {
        guard let storage else {
            logger.warning(
                "No storage available. Save operation is considered successful by default."
            )
            return .success
        }
        do {
            try await storage.save(navigationState)
            return .success
        } catch {
            return .failure(.save(error))
        }
    }

    /// Deletes the navigation state for the current stack.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the delete operation.
    /// - Throws: An error if the delete operation fails.
    @discardableResult
    public func delete() async throws -> NavigationResult {
        navigationState.removeValue(forKey: stack)
        return await performSaveOperation(
            "Deleting navigation stack '\(stack.id)'."
        )
    }

    /// Loads a previously saved navigation state from storage.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the load operation.
    /// - Throws: A `NavigationError.load` error if loading fails.
    @discardableResult
    public func load() async throws -> NavigationResult {
        guard let storage else {
            logger.warning(
                "No storage available. Load operation is considered successful by default."
            )
            return .success
        }
        do {
            if let loadedState = try await storage.load() {
                navigationState = loadedState
                logger.info("Successfully loaded navigation state from storage.")
                return .success
            }
            logger.warning("No navigation state found in storage.")
            return .failure(.pathNotFound)
        } catch {
            logger.error("Failed to load navigation state: \(error.localizedDescription)")
            return .failure(.load(error))
        }
    }
}
