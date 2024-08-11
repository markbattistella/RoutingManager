//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration that defines storage options for navigation data, providing built-in choices for
/// in-memory storage, file system storage, and custom storage implementations.
///
/// `NavigationStorageOption` is used to configure how navigation-related data, such as routes and
/// path identifiers, should be stored. It offers flexibility by allowing developers to choose between
/// storing data in memory, on the file system, or in a custom storage implementation.
///
/// - Note: The generic type `T` represents the type of data being stored, which must conform
/// to `Serializable`.
@MainActor
public enum NavigationStorageOption<T> where T: Serializable {

    /// Stores data in memory, providing a non-persistent storage option.
    case inMemory

    /// Stores data on the file system in the specified directory.
    ///
    /// - Parameter directory: The file system directory where data will be stored.
    /// Defaults to `.documentDirectory`.
    case fileSystem(directory: FileManager.SearchPathDirectory = .documentDirectory)

    /// Uses a custom storage implementation provided by the developer.
    ///
    /// - Parameter storage: A custom storage implementation conforming to `FileStorage<[T]>`.
    case custom(storage: FileStorage<[T]>)

    /// Creates a storage instance based on the selected storage option.
    ///
    /// - Returns: A `FileStorage` instance that handles storage according to the selected option.
    internal func createStorage() -> FileStorage<[T]> {
        switch self {
            case .inMemory:
                return FileStorage(InMemoryStorage<[T]>())
            case .fileSystem(let directory):
                return FileStorage(
                    JSONFileStorage<[T]>(directory: directory, filePrefix: "route_")
                )
            case .custom(let storage):
                return storage
        }
    }

    /// Creates a storage instance specifically for path identifiers, based on the selected
    /// storage option.
    ///
    /// - Returns: A `FileStorage` instance that handles storage for path identifiers according
    /// to the selected option.
    internal func createStorageForIdentifiers<U>() -> FileStorage<[U]> where U: Serializable {
        switch self {
            case .inMemory:
                return FileStorage(InMemoryStorage<[U]>())
            case .fileSystem(let directory):
                return FileStorage(
                    JSONFileStorage<[U]>(directory: directory, filePrefix: "path_")
                )
            case .custom(let storage):
                let customStorage = storage as? FileStorage<[U]>
                return customStorage ?? FileStorage(InMemoryStorage<[U]>())
        }
    }
}
