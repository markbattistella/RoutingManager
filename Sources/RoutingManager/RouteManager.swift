//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import Observation

/// A class that manages the navigation paths for an application, providing functionality to
/// save, load, and modify the current navigation state.
///
/// This class is designed to work with SwiftUI's navigation system and allows for seamless
/// navigation between views. The `RouteManager` class uses the `NavigationResult` type to
/// return results from navigation operations, with an optional `.navigationError {}` modifier
/// for handling errors.
@available(iOS 17.0, macOS 14.0, macCatalyst 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
@Observable final public class RouteManager<Route: NavigationRouteRepresentable> {

    /// The current navigation path, which is observed by SwiftUI views.
    public var routes: NavigationPath

    /// The storage mechanism used for saving and loading navigation paths.
    private let storage: NavigationPathStorage

    /// An optional identifier used to customize the storage location or filename.
    private var storageIdentifier: String?

    /// Initializes a new `RouteManager` with the specified storage mechanism and identifier.
    ///
    /// - Parameters:
    ///   - storage: The storage mechanism for saving and loading paths. Defaults to `FileNavigationPathStorage`.
    ///   - identifier: An optional identifier to customize the storage location or filename.
    public init(
        storage: NavigationPathStorage = FileNavigationPathStorage(),
        identifier: String? = nil
    ) {
        self.routes = NavigationPath()
        self.storage = storage
        self.storageIdentifier = identifier
    }

    /// Appends a new route to the navigation path, optionally saving the change.
    ///
    /// - Parameters:
    ///   - screen: The route to be added.
    ///   - save: If `true`, saves the updated navigation path. Defaults to `false`.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    ///
    /// - Note: You can chain the `.navigationError {}` modifier to handle errors if needed.
    ///
    /// - Example:
    /// ```swift
    /// routeManager.push(to: .details)
    ///     .navigationError { error in
    ///         print("Error pushing to details: \(error.localizedDescription)")
    ///     }
    /// ```
    @discardableResult
    public func push(to screen: Route, save: Bool = false) -> NavigationResult {
        do {
            routes.append(screen)
            if save {
                try saveCurrentPath()
            }
            return .success
        } catch let error as NavigationError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }

    /// Removes the last route from the navigation path, optionally saving the change.
    ///
    /// - Parameter save: If `true`, saves the updated navigation path. Defaults to `false`.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    ///
    /// - Note: You can chain the `.navigationError {}` modifier to handle errors if needed.
    ///
    /// - Example:
    /// ```swift
    /// routeManager.goBack(save: true)
    ///     .navigationError { error in
    ///         print("Error going back: \(error.localizedDescription)")
    ///     }
    /// ```
    @discardableResult
    public func goBack(save: Bool = false) -> NavigationResult {
        do {
            guard !routes.isEmpty else { return .failure(.routeNotFound) }
            routes.removeLast()
            if save {
                try saveCurrentPath()
            }
            return .success
        } catch let error as NavigationError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }

    /// Resets the navigation path to empty, optionally saving the change.
    ///
    /// - Parameter save: If `true`, saves the empty navigation path. Defaults to `false`.
    /// - Returns: A `NavigationResult` indicating the success or failure of the operation.
    ///
    /// - Note: You can chain the `.navigationError {}` modifier to handle errors if needed.
    ///
    /// - Example:
    /// ```swift
    /// routeManager.reset(save: true)
    ///     .navigationError { error in
    ///         print("Error resetting navigation: \(error.localizedDescription)")
    ///     }
    /// ```
    @discardableResult
    public func reset(save: Bool = false) -> NavigationResult {
        do {
            routes = NavigationPath()
            if save {
                try saveCurrentPath()
            }
            return .success
        } catch let error as NavigationError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }

    /// Saves the current navigation path to the specified storage.
    ///
    /// - Throws: An error if the path could not be saved.
    ///
    /// - Note: This method is used internally by `push`, `goBack`, and `reset` methods when `save` is `true`.
    public func saveCurrentPath() throws {
        let data = try JSONEncoder().encode(routes.codable)
        try storage.save(data: data, identifier: storageIdentifier)
    }

    /// Loads the last saved navigation path from storage and sets it as the current path.
    ///
    /// - Throws: An error if the path could not be loaded.
    ///
    /// - Note: This method should be called on the main thread as it modifies the UI state.
    @MainActor
    public func loadLastSavedPath() throws {
        let data = try storage.load(identifier: storageIdentifier)
        let codableRepresentation = try JSONDecoder()
            .decode(NavigationPath.CodableRepresentation.self, from: data)
        self.routes = NavigationPath(codableRepresentation)
    }
}
