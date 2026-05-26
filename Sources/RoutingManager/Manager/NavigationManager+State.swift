//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

extension NavigationManager: NavigationStateDelegate {

  /// Lists all routes currently present in the navigation state.
  ///
  /// - Returns: A dictionary mapping each `Stack` to its corresponding list of `Route` instances.
  @discardableResult
  public func listRoutes() -> [Stack: [Route]] {
    logger.info("Listing all routes in the navigation state.")
    return navigationState
  }

  /// Deletes the navigation state associated with the current stack.
  ///
  /// - Returns: A `NavigationResult` indicating success or failure of the delete operation.
  @discardableResult
  public func delete() -> NavigationResult {
    navigationState.removeValue(forKey: stack)
    return performSaveOperation("Deleting navigation stack '\(stack.id)'.")
  }

  /// Loads the navigation state from storage, if available.
  ///
  /// - Returns: A `NavigationResult` indicating success or failure of the load operation.
  @discardableResult
  public func load() -> NavigationResult {
    guard let storage else {
      logger.warning("No storage available. Load operation is considered successful by default.")
      return record(.success)
    }
    do {
      if let loadedState = try storage.load() {
        navigationState = loadedState
        logger.info("Successfully loaded navigation state from storage.")
        return record(.success)
      }
      logger.warning("No navigation state found in storage.")
      return record(.failure(.pathNotFound))
    } catch {
      logger.error("Failed to load navigation state: \(error.localizedDescription)")
      if let navigationError = error as? NavigationError {
        return record(.failure(navigationError))
      }
      return record(.failure(.load(error)))
    }
  }

  /// Persists the current navigation state to the configured storage.
  ///
  /// If `navigationState` is empty, the storage file is deleted instead of saved. If no storage
  /// is configured, the operation is considered successful.
  ///
  /// - Returns: A `NavigationResult` indicating whether the save or delete operation succeeded.
  @discardableResult
  internal func save() -> NavigationResult {
    guard let storage else {
      logger.warning("No storage available. Save operation is considered successful by default.")
      return record(.success)
    }

    do {
      if navigationState.isEmpty {
        try storage.delete()
      } else {
        try storage.save(navigationState)
      }
      return record(.success)
    } catch {
      if let navigationError = error as? NavigationError {
        return record(.failure(navigationError))
      }
      if navigationState.isEmpty {
        return record(.failure(.delete(error)))
      }
      return record(.failure(.save(error)))
    }
  }
}
