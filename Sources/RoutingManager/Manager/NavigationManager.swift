//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation
import Observation
import SimpleLogger
import SwiftUI

/// A class responsible for managing navigation state and persistence.
///
/// `NavigationManager` maintains the navigation stack, tracks navigation state, and optionally
/// persists state using different storage modes.
@Observable
public final class NavigationManager<Stack, Route>
where Stack: NavigationStackRepresentable, Route: NavigationRouteRepresentable {

    /// A logger instance for tracking navigation-related events.
    internal let logger = SimpleLogger(category: .navigation)

    /// The current navigation state, mapping each stack to its corresponding routes.
    internal var navigationState: [Stack: [Route]]

    /// The navigation stack associated with this manager.
    internal let stack: Stack

    /// The storage mechanism used for persisting navigation state, if applicable.
    internal let storage: FileStorage<[Stack: [Route]]>?

    /// The result of the last navigation operation.
    public private(set) var lastResult: NavigationResult

    /// Initializes a new `NavigationManager` for a given stack with a specified storage mode.
    ///
    /// - Parameters:
    ///   - stack: The navigation stack that this manager will operate on.
    ///   - storageMode: The mode of storage to be used for persisting navigation state.
    public init(
        for stack: Stack,
        storageMode: StorageMode = .memory
    ) {
        self.navigationState = [:]
        self.lastResult = .unknown
        self.stack = stack

        switch storageMode {
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

        /// Navigation state is stored in memory.
        case memory

        /// Navigation state is stored in a JSON file.
        case json

        /// A custom storage implementation is used.
        ///
        /// - Parameter customStorage: A `FileStorage` instance handling the custom storage mechanism.
        case custom(FileStorage<[Stack: [Route]]>)
    }
}
