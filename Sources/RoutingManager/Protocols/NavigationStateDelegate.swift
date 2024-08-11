//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol that defines the required methods for managing the state of navigation routes,
/// including saving, updating, loading, and deleting route stacks, as well as handling path 
/// identifiers.
///
/// This protocol is designed to be implemented by classes or structs that manage navigation states
/// with routes conforming to the `NavigationRouteRepresentable` protocol. The protocol is internal,
/// meaning it's only accessible within the module in which it's defined.
@MainActor
internal protocol NavigationStateDelegate: Sendable {

    /// The type of route that this delegate will manage.
    associatedtype Route: NavigationRouteRepresentable

    /// Saves the current route stack associated with a given identifier to persistent storage.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier to associate with the route stack.
    /// - Returns: The result of the save operation, indicating success or failure.
    @discardableResult
    func saveRouteStack(with identifier: PathIdentifier?) async -> NavigationResult

    /// Updates the route stack with a new set of routes and persists the changes.
    ///
    /// - Parameters:
    ///   - newRoutes: The new routes to update the stack with.
    ///   - identifier: The optional path identifier to associate with the updated routes.
    /// - Returns: The result of the update operation, indicating success or failure.
    @discardableResult
    func updateRoutes(_ newRoutes: [Route], for identifier: PathIdentifier?) async -> NavigationResult

    /// Updates the route stack with a new set of routes for a specific label and persists the changes.
    ///
    /// - Parameters:
    ///   - newRoutes: The new routes to update the stack with.
    ///   - label: The label associated with the path identifier.
    /// - Returns: The result of the update operation, indicating success or failure.
    /// - Throws: A `NavigationError` if the path identifier for the label cannot be found.
    @discardableResult
    func updateRoutes(_ newRoutes: [Route], for label: String) async throws -> NavigationResult

    /// Loads the route stack associated with a given identifier from persistent storage.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier associated with the route stack to load.
    /// - Returns: The result of the load operation, indicating success or failure.
    @discardableResult
    func loadRouteStack(with identifier: PathIdentifier?) async -> NavigationResult

    /// Deletes the route stack associated with a given identifier from persistent storage.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier associated with the route stack to delete.
    /// - Returns: The result of the delete operation, indicating success or failure.
    @discardableResult
    func deleteRouteStack(for identifier: PathIdentifier?) async -> NavigationResult

    /// Retrieves all path identifiers from persistent storage.
    ///
    /// - Returns: A result containing either an array of path identifiers or a navigation error.
    func getAllRoutes() async -> Result<[PathIdentifier], NavigationError>

    /// Retrieves a specific path identifier for a given label.
    ///
    /// - Parameters:
    ///   - label: The label associated with the path identifier.
    /// - Returns: The path identifier.
    /// - Throws: A `NavigationError` if the path identifier is not found.
    func getPathIdentifier(for label: String) async throws -> PathIdentifier
}
