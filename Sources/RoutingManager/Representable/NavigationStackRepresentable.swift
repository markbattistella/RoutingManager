//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation

/// A protocol that represents a navigation stack within a navigation system.
public protocol NavigationStackRepresentable: Representable where ID == String {

    /// A unique identifier for the navigation stack.
    var id: String { get }
}
