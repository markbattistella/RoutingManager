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
/// `NavigationStateDelegate` is designed to be implemented by classes or structs that manage
/// navigation states where routes conform to the `NavigationRouteRepresentable` protocol. This
/// protocol allows for the persistence and retrieval of navigation states, making it easier to
/// manage complex navigation flows in an application.
///
/// - Note: This protocol is `internal`, meaning it is only accessible within the module in which
/// it is defined. It is also marked with `@MainActor` to ensure that all operations are performed
/// on the main thread, which is necessary for UI updates.
@MainActor
internal protocol NavigationStateDelegate {

    /// The type of route that this delegate will manage.
    ///
    /// This associated type must conform to `NavigationRouteRepresentable`, ensuring that all
    /// routes managed by this delegate are uniquely identifiable and can be serialized for
    /// persistence.
    associatedtype Route: NavigationRouteRepresentable

    /// Saves the current route stack associated with a given identifier to persistent storage.
    ///
    /// This method saves the current state of the navigation stack, associating it with a specific
    /// path identifier. This allows the navigation state to be restored later. If no identifier is
    /// provided, the stack is saved with a default or existing identifier.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier to associate with the route stack. If `nil`,
    ///     a default identifier may be used.
    /// - Returns: The result of the save operation, indicating success or failure.
    @discardableResult
    func saveRouteStack(with identifier: PathIdentifier?) async -> NavigationResult

    /// Updates the route stack with a new set of routes and persists the changes.
    ///
    /// This method replaces the current navigation stack with a new set of routes and saves the
    /// updated stack to persistent storage. This is useful when the navigation state needs to be
    /// programmatically changed and persisted.
    ///
    /// - Parameters:
    ///   - newRoutes: The new routes to update the stack with. These routes must conform to
    ///     `NavigationRouteRepresentable`.
    ///   - identifier: The optional path identifier to associate with the updated routes. If `nil`,
    ///     a default identifier may be used.
    /// - Returns: The result of the update operation, indicating success or failure.
    @discardableResult
    func updateRoutes(_ newRoutes: [Route], for identifier: PathIdentifier?) async -> NavigationResult

    /// Updates the route stack with a new set of routes for a specific label and persists the changes.
    ///
    /// This method updates the navigation stack with a new set of routes associated with a specific
    /// label, then saves the updated stack to persistent storage. This is useful for managing
    /// navigation states that are identified by labels, allowing for more intuitive navigation
    /// management.
    ///
    /// - Parameters:
    ///   - newRoutes: The new routes to update the stack with. These routes must conform to
    ///     `NavigationRouteRepresentable`.
    ///   - label: The label associated with the path identifier. This is used to find the
    ///     appropriate path identifier for the update.
    /// - Returns: The result of the update operation, indicating success or failure.
    /// - Throws: A `NavigationError` if the path identifier for the label cannot be found.
    @discardableResult
    func updateRoutes(_ newRoutes: [Route], for label: String) async throws -> NavigationResult

    /// Loads the route stack associated with a given identifier from persistent storage.
    ///
    /// This method retrieves the navigation stack associated with the provided path identifier
    /// from persistent storage. This allows the application to restore a previously saved
    /// navigation state. If no identifier is provided, a default or existing identifier may be
    /// used.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier associated with the route stack to load. If
    ///     `nil`, a default identifier may be used.
    /// - Returns: The result of the load operation, indicating success or failure.
    @discardableResult
    func loadRouteStack(with identifier: PathIdentifier?) async -> NavigationResult

    /// Deletes the route stack associated with a given identifier from persistent storage.
    ///
    /// This method deletes the navigation stack associated with the provided path identifier from
    /// persistent storage. This is useful for removing outdated or no longer needed navigation
    /// states.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier associated with the route stack to delete. If
    ///     `nil`, a default identifier may be used.
    /// - Returns: The result of the delete operation, indicating success or failure.
    @discardableResult
    func deleteRouteStack(for identifier: PathIdentifier?) async -> NavigationResult

    /// Retrieves all path identifiers from persistent storage.
    ///
    /// This method returns a list of all path identifiers currently stored in persistent storage.
    /// These identifiers can be used to reference and manage different navigation states.
    ///
    /// - Returns: A result containing either an array of path identifiers or a navigation error.
    func getAllRoutes() async -> Result<[PathIdentifier], NavigationError>

    /// Retrieves a specific path identifier for a given label.
    ///
    /// This method finds and returns the path identifier associated with the specified label. If
    /// no identifier is found for the label, a `NavigationError` is thrown.
    ///
    /// - Parameters:
    ///   - label: The label associated with the path identifier. This label is used to search for
    ///     the corresponding identifier in persistent storage.
    /// - Returns: The path identifier associated with the label.
    /// - Throws: A `NavigationError` if the path identifier is not found.
    func getPathIdentifier(for label: String) async throws -> PathIdentifier
}
