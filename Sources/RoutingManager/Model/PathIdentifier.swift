//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A structure that uniquely identifies a navigation path using a UUID and an optional label.
///
/// `PathIdentifier` is used to distinguish different navigation paths within an application.
/// Each instance is uniquely identified by a UUID, ensuring that every navigation path can be
/// uniquely referenced. Additionally, a human-readable label can be provided to describe the
/// path, which is useful for debugging, logging, or displaying in the UI. The label is optional
/// and defaults to "default" if not provided.
///
/// - Note: This structure conforms to `Representable`, making it suitable for use in
/// serialization, collections, and as a key in dictionaries.
public struct PathIdentifier: Representable {

    /// A unique identifier for the navigation path.
    ///
    /// The `id` is generated using `UUID()`, ensuring that each `PathIdentifier` is globally
    /// unique. This allows navigation paths to be reliably distinguished from one another.
    public let id: UUID

    /// A human-readable label for the navigation path.
    ///
    /// The `label` provides additional context or description for the navigation path. This is
    /// particularly useful in scenarios where multiple paths are being managed, and a descriptive
    /// label can help differentiate them.
    public let label: String

    /// Initializes a new `PathIdentifier` with an optional label.
    ///
    /// This initializer creates a new `PathIdentifier`, generating a unique `UUID` for the
    /// identifier and accepting an optional label. If no label is provided, it defaults to
    /// "default".
    ///
    /// - Parameter identifier: A human-readable label for the navigation path. Defaults to "default".
    public init(label identifier: String = "default") {
        self.id = UUID()
        self.label = identifier
    }
}
