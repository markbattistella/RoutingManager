//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol defining operations for managing the state of a navigation stack.
///
/// The `NavigationStateDelegate` protocol provides methods to list, save, load, and delete
/// navigation states, allowing for persistent and dynamic navigation management.
@MainActor
internal protocol NavigationStateDelegate {

  /// The type that represents the navigation stack.
  associatedtype Stack: NavigationStackRepresentable

  /// The type that represents individual navigation routes.
  associatedtype Route: NavigationRouteRepresentable

  /// Retrieves a list of all routes currently present in the navigation stack.
  ///
  /// - Returns: A dictionary mapping each `Stack` to its corresponding list of `Route` instances.
  @discardableResult
  func listRoutes() -> [Stack: [Route]]

  /// Saves the current navigation state.
  ///
  /// - Returns: A `NavigationResult` indicating the success or failure of the save operation.
  @discardableResult
  func save() -> NavigationResult

  /// Loads a previously saved navigation state.
  ///
  /// - Returns: A `NavigationResult` indicating the success or failure of the load operation.
  @discardableResult
  func load() -> NavigationResult

  /// Deletes the saved navigation state.
  ///
  /// - Returns: A `NavigationResult` indicating the success or failure of the delete operation.
  @discardableResult
  func delete() -> NavigationResult
}
