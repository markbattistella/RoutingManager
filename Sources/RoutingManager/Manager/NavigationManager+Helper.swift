//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

// MARK: - Helpers

extension NavigationManager {

  /// Updates the stored route list for a stack, removing empty stacks entirely.
  internal func setRoutes(_ routes: [Route], for stack: Stack) {
    if routes.isEmpty {
      navigationState.removeValue(forKey: stack)
    } else {
      navigationState[stack] = routes
    }
  }

  /// Stores and returns the latest navigation result.
  @discardableResult
  internal func record(_ result: NavigationResult) -> NavigationResult {
    lastResult = result
    return result
  }

  /// Performs a save operation on the navigation state and logs the result.
  ///
  /// This method attempts to save the current navigation state and logs whether the save was
  /// successful or not. It returns a `NavigationResult` indicating the outcome.
  ///
  /// - Parameter actionDescription: A string describing the action being performed, used for
  /// logging.
  /// - Returns: A `NavigationResult` indicating success or failure of the save operation.
  @discardableResult
  internal func performSaveOperation(_ actionDescription: String) -> NavigationResult {
    logger.info("\(actionDescription, privacy: .public)")
    let result = save()
    if case .failure(let error) = result {
      logger.error("Failed to save navigation state: \(error.localizedDescription)")
    } else {
      logger.info("Successfully saved navigation state.")
    }
    return result
  }
}
