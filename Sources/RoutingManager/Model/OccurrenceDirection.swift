//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// Defines the direction in which to search for an occurrence of a navigation route.
public enum OccurrenceDirection: String {

    /// Represents the first occurrence of a route in the navigation stack.
    case first

    /// Represents the last occurrence of a route in the navigation stack.
    case last
}
