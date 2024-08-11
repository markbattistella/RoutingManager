//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI
import Observation

/// A class responsible for managing navigation state, routes, and persistence of route stacks.
///
/// The `NavigationManager` class provides a set of methods to navigate between screens,
/// save and load route stacks, and manage the persistence of navigation states.
/// It is designed to work with routes conforming to the `NavigationRouteRepresentable` protocol.
@Observable
public class NavigationManager<Route: NavigationRouteRepresentable> {

    // MARK: - Public Properties

    /// The current navigation path consisting of routes.
    public var routes: NavigationPath

    /// The result of the last navigation operation.
    /// This property is publicly accessible but can only be set internally.
    public private(set) var lastResult: NavigationResult

    // MARK: - Internal Properties

    /// A private storage for internal routes used to track the current navigation stack.
    private var _internalRoutes: [Route]

    /// The default path identifier used when no identifier is provided.
    private let defaultPathIdentifier: PathIdentifier

    /// File storage for saving and loading route stacks.
    private let routeFileStorage: FileStorage<[Route]>

    /// File storage for saving and loading path identifiers.
    private let pathFileStorage: FileStorage<[PathIdentifier]>

    // MARK: - Initialization

    /// Initializes a new instance of `NavigationManager` with the provided storage option and identifier.
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
    /// - Parameters:
    ///   - screens: The screens (routes) to push onto the stack.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
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
    /// - Parameters:
    ///   - numberOfScreens: The number of screens to remove from the stack, defaults to 1.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
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
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
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
    /// - Parameters:
    ///   - screen: The screen (route) to navigate to.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
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
    /// - Parameters:
    ///   - screen: The new screen (route) to replace the current route with.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
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
    /// - Parameters:
    ///   - routes: The new set of routes to replace the current stack.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
    @discardableResult
    public func replaceCurrentStack(with routes: [Route], for identifier: PathIdentifier?) -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        loadRoutes(routes, for: pathIdentifier)
        return lastResult
    }

    /// Resets the navigation stack to an empty state.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the navigation operation.
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
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the save operation.
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
    /// - Parameters:
    ///   - newRoutes: The new set of routes to update the stack with.
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the update operation.
    @discardableResult
    public func updateRoutes(_ newRoutes: [Route], for identifier: PathIdentifier? = nil) async -> NavigationResult {
        let pathIdentifier = getOrDefaultPathIdentifier(identifier)
        return await persistRoutes(newRoutes, for: pathIdentifier)
    }

    /// Updates the current route stack with a new set of routes for a specific label.
    ///
    /// - Parameters:
    ///   - newRoutes: The new set of routes to update the stack with.
    ///   - label: The label associated with the path identifier.
    /// - Returns: The result of the update operation.
    @discardableResult
    public func updateRoutes(_ newRoutes: [Route], for label: String) async throws -> NavigationResult {
        let identifier = try await getPathIdentifier(for: label)
        return await persistRoutes(newRoutes, for: identifier)
    }

    /// Loads the route stack from persistent storage.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the load operation.
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
    /// - Parameters:
    ///   - identifier: The optional path identifier, defaults to `nil`.
    /// - Returns: The result of the delete operation.
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

extension NavigationManager {

    /// Returns the provided path identifier or the default if `nil`.
    ///
    /// - Parameters:
    ///   - identifier: The optional path identifier.
    /// - Returns: The provided identifier or the default.
    private func getOrDefaultPathIdentifier(_ identifier: PathIdentifier?) -> PathIdentifier {
        return identifier ?? defaultPathIdentifier
    }

    /// Persists the current route stack to storage.
    ///
    /// - Parameters:
    ///   - identifier: The path identifier for the stack.
    /// - Returns: The result of the save operation.
    private func persistRouteStack(for identifier: PathIdentifier) async -> NavigationResult {
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
    /// - Parameters:
    ///   - newRoutes: The new routes to persist.
    ///   - identifier: The path identifier for the stack.
    /// - Returns: The result of the save operation.
    private func persistRoutes(_ newRoutes: [Route], for identifier: PathIdentifier) async -> NavigationResult {
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
    /// - Parameters:
    ///   - routes: The routes to load.
    ///   - identifier: The path identifier for the stack.
    private func loadRoutes(_ routes: [Route], for identifier: PathIdentifier) {
        _internalRoutes = routes
        self.routes = NavigationPath()
        routes.forEach { self.routes.append($0) }
    }

    /// Updates the `lastResult` property on the main thread.
    ///
    /// - Parameters:
    ///   - result: The result to set as the last result.
    private func updateLastResult(_ result: NavigationResult) {
        DispatchQueue.main.async {
            self.lastResult = result
        }
    }
}
