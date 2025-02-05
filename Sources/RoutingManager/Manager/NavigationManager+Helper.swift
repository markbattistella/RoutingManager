//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

extension NavigationManager {
    
    /// Performs a save operation on the navigation state and logs the action.
    ///
    /// This method attempts to save the current navigation state asynchronously and logs the result.
    ///
    /// - Parameter actionDescription: A string describing the navigation action being performed.
    /// - Returns: A `NavigationResult` indicating whether the save operation was successful.
    @discardableResult
    internal func performSaveOperation(_ actionDescription: String) async -> NavigationResult {
        logger.info("\(actionDescription, privacy: .public)")
        do {
            let result = try await save()
            logger.info("Successfully saved navigation state.")
            return result
        } catch {
            logger.error("Failed to save navigation state: \(error.localizedDescription)")
            return .failure(.save(error))
        }
    }
}
