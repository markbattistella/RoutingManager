//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A typealias that combines `Codable`, `Identifiable`, and `Hashable` protocols.
///
/// `Representable` is a convenient shorthand for types that need to be serializable (`Codable`),
/// uniquely identifiable (`Identifiable`), and usable in collections (`Hashable`).
public typealias Representable = Codable & Identifiable & Hashable
