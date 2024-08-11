//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A structure that uniquely identifies a navigation path using a UUID and an optional label.
///
/// `PathIdentifier` is used to distinguish different navigation paths, both by a unique 
/// identifier (UUID) and a human-readable label. The label is optional and defaults to "default".
///
/// - Note: This structure conforms to `Codable` and `Hashable`, making it suitable for use in 
/// serialization and collections.
public struct PathIdentifier: Codable, Hashable {

    /// A unique identifier for the navigation path.
    public let id: UUID

    /// A human-readable label for the navigation path.
    public let label: String
    
    /// Initializes a new `PathIdentifier` with an optional label.
    ///
    /// - Parameter label: A human-readable label for the navigation path. Defaults to "default".
    public init(label: String = "default") {
        self.id = UUID()
        self.label = label
    }
}
