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
///
/// - Note: The default `id` is a convenient hierarchical description:
///   - Simple cases: `Stack.AppStack.main`
///   - Cases with associated values: `Stack.AppStack.userProfile.abc123`
///   - Override `id` with an explicit value for durable deep links or persistence across schema changes.
public protocol NavigationStackRepresentable: Representable where ID == String {
    /// The unique identifier for the navigation stack.
    var id: String { get }
}

extension NavigationStackRepresentable {
    public var id: String {
        generateNavigationIdentifier(for: self, prefix: "Stack")
    }
}
