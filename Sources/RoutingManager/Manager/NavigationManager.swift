//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation
import Observation
import SimpleLogger

/// A navigation manager responsible for handling navigation state and persistence.
///
/// `NavigationManager` manages a navigation stack by storing and retrieving navigation states. It
/// supports different storage modes, including memory-based and JSON file-based persistence.
///
/// - Parameters:
///   - `Stack`: A type conforming to `NavigationStackRepresentable`, representing different
///   navigation stacks.
///   - `Route`: A type conforming to `NavigationRouteRepresentable`, representing individual
///   navigation destinations.
@Observable
public final class NavigationManager<Stack, Route> where Stack: NavigationStackRepresentable, Route: NavigationRouteRepresentable {
    
    /// A simple logger for debugging navigation events.
    internal let logger = SimpleLogger(category: .navigation)
    
    /// A dictionary that holds the navigation state, mapping stacks to their corresponding routes.
    internal var navigationState: [Stack: [Route]]
    
    /// The current navigation stack being managed.
    internal let stack: Stack
    
    /// The storage mechanism used for persisting navigation state.
    ///
    /// If `nil`, navigation state is not persisted.
    internal let storage: FileStorage<[Stack: [Route]]>?
    
    /// The result of the last navigation operation.
    ///
    /// This value provides feedback on whether the last navigation action was successful.
    public private(set) var lastResult: NavigationResult
    
    /// Initializes a `NavigationManager` for a specific navigation stack.
    ///
    /// - Parameters:
    ///   - stack: The navigation stack associated with this manager.
    ///   - storageMode: The mode of storage to use for persisting navigation state.
    public init(
        for stack: Stack,
        storageMode: StorageMode = .memory
    ) {
        self.navigationState = [:]
        self.lastResult = .unknown
        self.stack = stack
        
        switch storageMode {
            case .none:
                self.storage = nil
            case .memory:
                self.storage = FileStorage(MemoryStorage())
            case .json:
                self.storage = FileStorage(JSONFileStorage())
            case .custom(let customStorage):
                self.storage = customStorage
        }
    }
    
    /// Defines the available storage modes for persisting navigation state.
    public enum StorageMode {
        
        /// No storage is used; navigation state is not persisted.
        case none
        
        /// Uses an in-memory storage that resets when the app restarts.
        case memory
        
        /// Uses JSON file storage to persist navigation state across app launches.
        case json
        
        /// Allows custom storage implementations.
        case custom(FileStorage<[Stack: [Route]]>)
    }
}
