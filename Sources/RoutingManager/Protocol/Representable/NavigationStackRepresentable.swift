//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol representing a navigation stack within a navigation system.
///
/// `NavigationStackRepresentable` defines a stack that conforms to `Representable` and is
/// identified by a `String` ID.
public protocol NavigationStackRepresentable: Representable where ID == String {

    /// The unique identifier for the navigation stack.
    var id: String { get }
}
