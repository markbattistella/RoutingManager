//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A typealias that combines multiple protocol conformances for representable models.
///
/// Types conforming to `Representable` must also conform to:
/// - `Codable` for encoding and decoding support.
/// - `Identifiable` to provide a unique identity.
/// - `Hashable` to enable hashing and comparison.
public typealias Representable = Codable & Identifiable & Hashable
