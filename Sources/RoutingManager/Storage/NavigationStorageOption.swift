//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration that defines different storage options for managing navigation data, including
/// in-memory storage, file system storage, and custom storage implementations.
///
/// `NavigationStorageOption` provides flexibility in how navigation data is stored, whether it
/// needs to be persisted across app launches or only stored temporarily in memory. This enum also
/// allows for custom storage solutions, giving developers the ability to define their own storage
/// mechanisms.
///
/// - Type Parameters:
///   - `T`: The type of data to be stored, which must conform to `Serializable`.
public enum NavigationStorageOption<T> where T: Serializable {

    /// Stores data in memory, providing a non-persistent storage option.
    ///
    /// Use this option when persistence is not required, such as for caching or temporary data
    /// storage during a single session.
    case inMemory

    /// Stores data on the file system in the specified directory.
    ///
    /// This option provides persistent storage, allowing data to be saved to a directory on the
    /// file system. It is useful for saving navigation data that needs to persist across app
    /// launches.
    ///
    /// - Parameter directory: The file system directory where data will be stored.
    ///   Defaults to `.documentDirectory`.
    case fileSystem(directory: FileManager.SearchPathDirectory = .documentDirectory)

    /// Uses a custom storage implementation provided by the developer.
    ///
    /// This option allows for custom storage mechanisms, enabling developers to define how data
    /// should be stored and retrieved. The custom storage must conform to `FileStorage<[T]>`.
    ///
    /// - Parameter storage: A custom storage implementation conforming to `FileStorage<[T]>`.
    case custom(storage: FileStorage<[T]>)

    /// Creates a storage instance based on the selected storage option.
    ///
    /// This method returns a `FileStorage` instance configured according to the selected storage
    /// option. It abstracts away the details of the storage implementation, providing a
    /// consistent interface for managing navigation data.
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
    /// This method returns a `FileStorage` instance configured to handle storage for path
    /// identifiers, ensuring that the same storage mechanism is used consistently for both
    /// navigation data and path identifiers.
    ///
    /// - Returns: A `FileStorage` instance that handles storage for path identifiers according
    ///   to the selected option.
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
