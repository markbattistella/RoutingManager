//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import Observation


/// A class responsible for managing navigation state, routes, and the persistence of route stacks.
///
/// The `NavigationManager` class provides a robust set of methods for navigating between screens,
/// saving and loading route stacks, and managing the persistence of navigation states. It is
/// designed to work with routes conforming to the `NavigationRouteRepresentable` protocol,
/// ensuring type safety and consistency across different navigation paths.
///
/// This class leverages the power of Swift's concurrency model by using `@MainActor` and
/// `@Observable`, making it suitable for integration with SwiftUI applications where the UI
/// needs to react to changes in the navigation state.
///
/// - Note: The `NavigationManager` class is marked as `Sendable`, making it safe to use in
///   concurrent contexts.
@available(iOS 17.0, macOS 14.0, macCatalyst 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
@MainActor
@Observable
public final class NavigationManager<Route> where Route: NavigationRouteRepresentable {

    // MARK: - Public Properties

    /// The current navigation path consisting of routes.
    ///
    /// This property holds the active navigation path, allowing you to track the sequence of
    /// routes the user has navigated through.
    public var routes: NavigationPath

    /// The result of the last navigation operation.
    ///
    /// This property records the outcome of the most recent navigation action, such as pushing
    /// or popping a route. It is publicly accessible but can only be set internally.
    public private(set) var lastResult: NavigationResult

    // MARK: - Internal Properties

    /// A private storage for internal routes used to track the current navigation stack.
    ///
    /// This array maintains the sequence of routes that are currently active in the navigation
    /// stack. It is used internally to manage navigation operations like popping and replacing
    /// routes.
    private var _internalRoutes: [Route]

    /// The default path identifier used when no identifier is provided.
    ///
    /// This identifier is used to manage navigation paths when no specific identifier is given
    /// during navigation operations.
    private let defaultPathIdentifier: PathIdentifier

    /// File storage for saving and loading route stacks.
    ///
    /// This property manages the storage of route stacks, allowing them to be persisted across
    /// app sessions.
    private let routeFileStorage: FileStorage<[Route]>

    /// File storage for saving and loading path identifiers.
    ///
    /// This property manages the storage of path identifiers, ensuring that navigation paths
    /// can be saved and retrieved reliably.
    private let pathFileStorage: FileStorage<[PathIdentifier]>

    // MARK: - Initialization

    /// Initializes a new instance of `NavigationManager` with the provided storage option and identifier.
    ///
    /// This initializer sets up the navigation manager with the specified storage option,
    /// determining whether navigation states are stored in memory, on the file system, or using
    /// a custom storage solution. It also sets up a default path identifier.
    ///
    /// - Parameters:
    ///   - storage: The storage option for saving routes and identifiers, defaults to in-memory storage.
    ///   - label: The label for the default path identifier, defaults to "default".
    public init(
        storage: NavigationStorageOption<Route> = .inMemory,
        identifier label: String = "default"
    ) {
        self.routes = NavigationPath()
        self._internalRoutes = []
        self.routeFileStorage = storage.createStorage()
        self.pathFileStorage = storage.createStorageForIdentifiers()
        self.defaultPathIdentifier = PathIdentifier(label: label)
        self.lastResult = .success
    }
}

// MARK: - NavigationRouteDelegate Implementation

extension NavigationManager: NavigationRouteDelegate {

    /// Pushes one or more routes onto the navigation stack.
    ///
    /// This method adds the specified routes to the end of the navigation stack, effectively
    /// navigating forward to the new routes. The operation's result is stored in `lastResult`.
    ///
    /// - Parameters:
    ///   - screens: The screens (routes) to push onto the stack.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func push(to screens: Route..., for identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        for screen in screens {
            self.routes.append(screen)
            self._internalRoutes.append(screen)
        }
        saveRouteStack(with: pathIdentifier)
        return lastResult
    }

    /// Navigates back by removing a specified number of screens from the navigation stack.
    ///
    /// This method pops the specified number of routes from the end of the navigation stack,
    /// effectively navigating backward. If the number of routes to remove exceeds the current
    /// stack size, all routes are removed.
    ///
    /// - Parameters:
    ///   - numberOfScreens: The number of screens to remove from the stack, defaults to 1.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func goBack(_ numberOfScreens: Int = 1, for identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        let screensToRemove = min(numberOfScreens, self.routes.count)
        self.routes.removeLast(screensToRemove)
        self._internalRoutes.removeLast(screensToRemove)
        saveRouteStack(with: pathIdentifier)
        return lastResult
    }

    /// Navigates to the first occurrence of a specific route in the navigation stack.
    ///
    /// This method searches the navigation stack for the first occurrence of the specified route
    /// and navigates to it by removing any routes that follow it. If the route is not found, the
    /// operation fails.
    ///
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func goToFirstOccurrence(of screen: Route, for identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        if let index = self._internalRoutes.firstIndex(where: { $0.id == screen.id }) {
            let numberToPop = self._internalRoutes.count - index - 1
            self.routes.removeLast(numberToPop)
            self._internalRoutes.removeLast(numberToPop)
            saveRouteStack(with: pathIdentifier)
            return lastResult
        }
        return .failure(.pathNotFound)
    }

    /// Navigates to the last occurrence of a specific route in the navigation stack.
    ///
    /// This method searches the navigation stack for the last occurrence of the specified route
    /// and navigates to it by removing any routes that follow it. If the route is not found, the
    /// operation fails.
    ///
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func goToLastOccurrence(of screen: Route, for identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        if let index = self._internalRoutes.lastIndex(where: { $0.id == screen.id }) {
            let numberToPop = self._internalRoutes.count - index - 1
            self.routes.removeLast(numberToPop)
            self._internalRoutes.removeLast(numberToPop)
            saveRouteStack(with: pathIdentifier)
            return lastResult
        }
        return .failure(.pathNotFound)
    }

    /// Replaces the current route in the navigation stack with a new route.
    ///
    /// This method removes the last route in the navigation stack and replaces it with the
    /// specified route. If the stack is empty, it simply adds the new route.
    ///
    /// - Parameters:
    ///   - screen: The new screen (route) to replace the current route with.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func replaceCurrent(with screen: Route, for identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        if !self.routes.isEmpty {
            self.routes.removeLast()
            self._internalRoutes.removeLast()
        }
        self.routes.append(screen)
        self._internalRoutes.append(screen)
        saveRouteStack(with: pathIdentifier)
        return lastResult
    }

    /// Replaces the entire current navigation stack with a new set of routes.
    ///
    /// This method clears the current navigation stack and replaces it with the specified set of
    /// routes, effectively resetting the navigation to the new stack.
    ///
    /// - Parameters:
    ///   - routes: The new set of routes to replace the current stack.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func replaceCurrentStack(with routes: [Route], for identifier: PathIdentifier?) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        loadRoutes(routes, for: pathIdentifier)
        return lastResult
    }

    /// Resets the navigation stack to an empty state.
    ///
    /// This method clears all routes from the navigation stack, effectively resetting the
    /// navigation history. The operation result is stored in `lastResult`.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation, indicating success or failure.
    @discardableResult
    public func resetNavigation(for identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        self.routes = NavigationPath()
        self._internalRoutes = []
        saveRouteStack(with: pathIdentifier)
        return lastResult
    }
}

// MARK: - NavigationStateDelegate Implementation

extension NavigationManager: NavigationStateDelegate {

    /// Saves the current route stack to persistent storage.
    ///
    /// This method asynchronously saves the current navigation stack to the designated storage
    /// option. It associates the stack with the provided path identifier, allowing it to be
    /// restored later.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the save operation, indicating success or failure.
    @discardableResult
    public func saveRouteStack(with identifier: PathIdentifier? = nil) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        Task {
            let result = await persistRouteStack(for: pathIdentifier)
            updateLastResult(result)
        }
        return lastResult
    }

    /// Updates the current route stack with a new set of routes and persists them.
    ///
    /// This method asynchronously updates the navigation stack with a new set of routes and
    /// saves the updated stack to persistent storage.
    ///
    /// - Parameters:
    ///   - newRoutes: The new set of routes to update the stack with.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the update operation, indicating success or failure.
    @discardableResult
    public func updateRoutes(_ newRoutes: [Route], for identifier: PathIdentifier? = nil) async -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        return await persistRoutes(newRoutes, for: pathIdentifier)
    }

    /// Updates the current route stack with a new set of routes for a specific label.
    ///
    /// This method asynchronously updates the navigation stack with a new set of routes for a
    /// specific path identifier label and saves the updated stack to persistent storage.
    ///
    /// - Parameters:
    ///   - newRoutes: The new set of routes to update the stack with.
    ///   - label: The label associated with the path identifier.
    /// - Returns: The result of the update operation, indicating success or failure.
    /// - Throws: A `NavigationError` if the path identifier for the label cannot be found.
    @discardableResult
    public func updateRoutes(_ newRoutes: [Route], for label: String) async throws -> NavigationResult {
        let identifier = try await getPathIdentifier(for: label)
        return await persistRoutes(newRoutes, for: identifier)
    }

    /// Loads the route stack from persistent storage.
    ///
    /// This method asynchronously loads the navigation stack associated with the specified path
    /// identifier from persistent storage and sets it as the current navigation stack.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the load operation, indicating success or failure.
    @discardableResult
    public func loadRouteStack(with identifier: PathIdentifier? = nil) async -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        let result: NavigationResult
        do {
            if let savedRoutes = try await routeFileStorage.load(for: pathIdentifier.id.uuidString) {
                loadRoutes(savedRoutes, for: pathIdentifier)
                result = .success
            } else {
                result = .failure(.pathNotFound)
            }
        } catch {
            result = .failure(.loadError(error))
        }
        updateLastResult(result)
        return result
    }

    /// Deletes the route stack associated with a specific identifier from persistent storage.
    ///
    /// This method asynchronously removes the navigation stack associated with the specified path
    /// identifier from persistent storage, ensuring that it cannot be restored later.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the delete operation, indicating success or failure.
    @discardableResult
    public func deleteRouteStack(for identifier: PathIdentifier? = nil) async -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        do {
            try await routeFileStorage.delete(for: pathIdentifier.id.uuidString)
            var savedIdentifiers = try await pathFileStorage.load(for: "pathIndex") ?? []
            savedIdentifiers.removeAll { $0.id == pathIdentifier.id }
            try await pathFileStorage.save(savedIdentifiers, as: "pathIndex")
            return .success
        } catch {
            return .failure(.deleteError(error))
        }
    }

    /// Retrieves all path identifiers from persistent storage.
    ///
    /// This method asynchronously retrieves all stored path identifiers, which can be used to
    /// identify and load different navigation stacks.
    ///
    /// - Returns: A result containing either an array of path identifiers or a navigation error.
    public func getAllRoutes() async -> Result<[PathIdentifier], NavigationError> {
        do {
            let paths = try await pathFileStorage.load(for: "pathIndex") ?? []
            return .success(paths)
        } catch {
            return .failure(.fileSystemError(error))
        }
    }

    /// Retrieves a specific path identifier for a given label.
    ///
    /// This method asynchronously retrieves the path identifier associated with the specified
    /// label from persistent storage. If the identifier is not found, an error is thrown.
    ///
    /// - Parameters:
    ///   - label: The label associated with the path identifier.
    /// - Returns: The path identifier.
    /// - Throws: A `NavigationError` if the path identifier is not found.
    public func getPathIdentifier(for label: String) async throws -> PathIdentifier {
        let savedIdentifiers = try await pathFileStorage.load(for: "pathIndex") ?? []
        if let matchingIdentifier = savedIdentifiers.first(where: { $0.label == label }) {
            return matchingIdentifier
        } else {
            throw NavigationError.pathIdentifierNotFound(label)
        }
    }
}

// MARK: - Private Helpers

fileprivate extension NavigationManager {

    /// Returns the provided path identifier or the default if `nil`.
    ///
    /// This method is used internally to ensure that navigation operations have a valid path
    /// identifier, defaulting to the instance's `defaultPathIdentifier` if none is provided.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier.
    /// - Returns: The provided identifier or the default.
    func getOrDefaultPathIdentifier(_ identifier: PathIdentifier?) -> PathIdentifier {
        return identifier ?? defaultPathIdentifier
    }

    /// Persists the current route stack to storage.
    ///
    /// This method asynchronously saves the internal route stack to the designated storage,
    /// associating it with the specified path identifier. The operation's result is returned
    /// as a `NavigationResult`.
    ///
    /// - Parameters:
    ///   - identifier: The path identifier for the stack.
    /// - Returns: The result of the save operation, indicating success or failure.
    func persistRouteStack(for identifier: PathIdentifier) async -> NavigationResult {
        do {
            try await routeFileStorage.save(_internalRoutes, as: identifier.id.uuidString)
            var savedIdentifiers = try await pathFileStorage.load(for: "pathIndex") ?? []
            if !savedIdentifiers.contains(where: { $0.id == identifier.id }) {
                savedIdentifiers.append(identifier)
            }
            try await pathFileStorage.save(savedIdentifiers, as: "pathIndex")
            return .success
        } catch {
            return .failure(.saveError(error))
        }
    }

    /// Persists a new set of routes to storage.
    ///
    /// This method asynchronously saves a new set of routes to the designated storage, replacing
    /// the current navigation stack associated with the specified path identifier.
    ///
    /// - Parameters:
    ///   - newRoutes: The new routes to persist.
    ///   - identifier: The path identifier for the stack.
    /// - Returns: The result of the save operation, indicating success or failure.
    func persistRoutes(_ newRoutes: [Route], for identifier: PathIdentifier) async -> NavigationResult {
        do {
            try await routeFileStorage.save(newRoutes, as: identifier.id.uuidString)
            var savedIdentifiers = try await pathFileStorage.load(for: "pathIndex") ?? []
            if !savedIdentifiers.contains(where: { $0.id == identifier.id }) {
                savedIdentifiers.append(identifier)
            }
            try await pathFileStorage.save(savedIdentifiers, as: "pathIndex")
            _internalRoutes = newRoutes
            routes = NavigationPath()
            newRoutes.forEach { routes.append($0) }
            return .success
        } catch {
            return .failure(.saveError(error))
        }
    }

    /// Loads a set of routes into the navigation stack.
    ///
    /// This method updates the current navigation stack with the specified set of routes and
    /// updates the internal route tracking accordingly.
    ///
    /// - Parameters:
    ///   - routes: The routes to load.
    ///   - identifier: The path identifier for the stack.
    func loadRoutes(_ routes: [Route], for identifier: PathIdentifier) {
        _internalRoutes = routes
        self.routes = NavigationPath()
        routes.forEach { self.routes.append($0) }
    }

    /// Updates the `lastResult` property on the main thread.
    ///
    /// This method is used internally to update the `lastResult` property with the result of
    /// the most recent navigation or storage operation.
    ///
    /// - Parameters:
    ///   - result: The result to set as the last result.
    func updateLastResult(_ result: NavigationResult) {
        self.lastResult = result
    }
}

extension NavigationManager: Sendable {}
