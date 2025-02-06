//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// An enumeration representing the direction in which to search for an occurrence of a navigation
/// route.
///
/// `OccurrenceDirection` is used when navigating to a specific occurrence of a screen
/// in the navigation stack, such as the first or last instance.
public enum OccurrenceDirection: String {

    /// The first occurrence of the specified screen in the navigation stack.
    case first

    /// The last occurrence of the specified screen in the navigation stack.
    case last
}
