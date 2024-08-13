//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A typealias that combines the `Codable` and `Sendable` protocols.
///
/// `Serializable` is used for types that need to be encoded and decoded for data persistence,
/// and also need to be safely passed across concurrency domains.
/// This is especially useful in contexts where data needs to be serialized and used in a
/// multi-threaded environment.
public typealias Serializable = Codable & Sendable

/// A typealias that combines the `Identifiable` and `Hashable` protocols.
///
/// `ViewRepresentable` is used for types that need to be uniquely identifiable, and hashable
/// (for use in collections like dictionaries and sets).
public typealias ViewRepresentable = Identifiable & Hashable

/// A typealias that combines the `ViewRepresentable` and `Serializable` typealiases.
///
/// `Representable` is used for types that need to be identifiable, hashable, encodable,
/// decodable, and safe to use across concurrency domains. This typealias is useful in scenarios
/// where you need a type that can be persisted, and identified uniquely, all while ensuring
/// thread safety.
public typealias Representable = ViewRepresentable & Serializable
