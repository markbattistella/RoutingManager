//
// Project: EmbeeKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A concrete implementation of `NavigationPathStorage` that saves and loads navigation data 
/// using the file system.
public struct FileNavigationPathStorage: NavigationPathStorage {

    private let fileManager = FileManager.default

    /// Initializes a new instance of `FileNavigationPathStorage`.
    public init() {}

    /// Computes the file path for storing or retrieving navigation path data based on an identifier.
    ///
    /// - Parameter identifier: An optional identifier to customize the filename. If `nil`, a 
    /// default filename is used.
    /// - Returns: A URL representing the file path for the specified identifier.
    private func getFilePath(for identifier: String? = nil) -> URL {
        let fileName = identifier.map { "\($0)NavigationPath.json" } ?? "defaultNavigationPath.json"
        let documentDirectory = fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        return documentDirectory.appendingPathComponent(fileName)
    }

    /// Saves data to the file system with encryption.
    /// - Parameters:
    ///   - data: The data to be saved.
    ///   - identifier: An optional identifier to customize the filename.
    /// - Throws: An error if the data could not be saved.
    public func save(data: Data, identifier: String?) throws {
        let path = getFilePath(for: identifier)
        try data.write(to: path, options: [.atomic, .completeFileProtection])
    }

    /// Loads data from the file system with encryption support.
    /// - Parameter identifier: An optional identifier to customize the filename.
    /// - Returns: The data loaded from the file system.
    /// - Throws: An error if the data could not be loaded.
    public func load(identifier: String?) throws -> Data {
        let path = getFilePath(for: identifier)
        return try Data(contentsOf: path, options: .mappedIfSafe)
    }
}

/// Manages the navigation paths for an application, providing functionality to save, load, and 
/// modify the current navigation state.
@available(iOS 16.0, macOS 13.0, *)
final public class RouteManager<Route: NavigationRouteRepresentable>: ObservableObject {

    /// The current navigation path, observable for SwiftUI views.
    @Published
    public var routes: NavigationPath

    private let storage: NavigationPathStorage
    private var storageIdentifier: String?

    /// Initializes a new `RouteManager` with the specified storage mechanism and identifier.
    ///
    /// - Parameters:
    ///   - storage: The storage mechanism for saving and loading paths. Defaults to 
    ///   `FileNavigationPathStorage`.
    ///   - identifier: An optional identifier to customize the storage location or filename.
    public init(
        storage: NavigationPathStorage = FileNavigationPathStorage(),
        identifier: String? = nil
    ) {
        self.routes = NavigationPath()
        self.storage = storage
        self.storageIdentifier = identifier
    }

    /// Saves the current navigation path to storage.
    public func saveCurrentPath() throws {
        do {
            let data = try JSONEncoder().encode(routes.codable)
            try storage.save(data: data, identifier: storageIdentifier)
        } catch {
            throw error
        }
    }

    /// Loads the last saved navigation path from storage.
    public func loadLastSavedPath() throws {
        do {
            let data = try storage.load(identifier: storageIdentifier)
            let codableRepresentation = try JSONDecoder()
                .decode(NavigationPath.CodableRepresentation.self, from: data)
            DispatchQueue.main.async {
                self.routes = NavigationPath(codableRepresentation)
            }
        } catch {
            throw error // Propagate the error upwards.
        }
    }

    /// Removes the last route from the navigation path, optionally saving the change.
    ///
    /// - Parameter save: If `true`, saves the updated navigation path. Defaults to `false`.
    public func goBack(save: Bool = false) {
        guard !routes.isEmpty else { return }
        routes.removeLast()
        if save {
            do {
                try saveCurrentPath()
            } catch {
                print("Error saving after going back: \(error.localizedDescription)")
            }
        }
    }

    /// Appends a new route to the navigation path, optionally saving the change.
    ///
    /// - Parameters:
    ///   - screen: The route to be added.
    ///   - save: If `true`, saves the updated navigation path. Defaults to `false`.
    public func push(to screen: Route, save: Bool = false) {
        routes.append(screen)
        if save {
            do {
                try saveCurrentPath()
            } catch {
                print("Error saving after pushing a new screen: \(error.localizedDescription)")
            }
        }
    }

    /// Resets the navigation path to empty, optionally saving the change.
    ///
    /// - Parameter save: If `true`, saves the empty navigation path. Defaults to `false`.
    public func reset(save: Bool = false) {
        routes = NavigationPath()
        if save {
            do {
                try saveCurrentPath()
            } catch {
                print("Error saving after resetting: \(error.localizedDescription)")
            }
        }
    }
}
