//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A typealias that combines the `Codable` and `Sendable` protocols.
///
/// `Serializable` is used for types that need to be encoded and decoded for data persistence,
/// and also need to be safely passed across concurrency domains.
/// This is especially useful in contexts where data needs to be serialized and used in a
/// multi-threaded environment.
public typealias Serializable = Codable & Sendable

/// A typealias that combines the `Identifiable`, `Hashable`, and `View` protocols.
///
/// `ViewRepresentable` is used for types that need to be uniquely identifiable, hashable
/// (for use in collections like dictionaries and sets), and also need to be represented
/// as a SwiftUI view. This is useful for defining view models or views that are used in
/// SwiftUI applications, where unique identification and hashing are often required.
public typealias ViewRepresentable = Identifiable & Hashable & View

/// A typealias that combines the `ViewRepresentable` and `Serializable` typealiases.
///
/// `Representable` is used for types that need to be identifiable, hashable, viewable as a
/// SwiftUI view, encodable, decodable, and safe to use across concurrency domains. This
/// typealias is useful in scenarios where you need a type that can be persisted, identified
/// uniquely, and rendered in a SwiftUI view, all while ensuring thread safety.
public typealias Representable = ViewRepresentable & Serializable
