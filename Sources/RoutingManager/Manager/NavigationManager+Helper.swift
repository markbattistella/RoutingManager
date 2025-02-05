//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

// MARK: - Helpers

extension NavigationManager {

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
