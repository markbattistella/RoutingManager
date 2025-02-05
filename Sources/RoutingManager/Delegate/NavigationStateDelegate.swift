//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A delegate protocol responsible for managing and persisting navigation state.
internal protocol NavigationStateDelegate {

    /// The type representing the navigation stack.
    associatedtype Stack: NavigationStackRepresentable

    /// The type representing a navigable route.
    associatedtype Route: NavigationRouteRepresentable

    /// Lists all routes currently stored within the navigation state, organized by stack.
    ///
    /// - Returns: A dictionary mapping each stack to its corresponding list of routes.
    @discardableResult
    func listRoutes() -> [Stack: [Route]]

    /// Saves the current navigation state persistently.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the save operation.
    /// - Throws: An error if the save operation fails.
    @discardableResult
    func save() async throws -> NavigationResult

    /// Loads a previously saved navigation state.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the load operation.
    /// - Throws: An error if the load operation fails.
    @discardableResult
    func load() async throws -> NavigationResult

    /// Deletes any stored navigation state, resetting it.
    ///
    /// - Returns: A `NavigationResult` indicating the success or failure of the delete operation.
    /// - Throws: An error if the delete operation fails.
    @discardableResult
    func delete() async throws -> NavigationResult
}
