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
/// - Note: The `id` property is automatically generated using a stable, hierarchical format:
///   - Simple cases: `Stack.AppStack.main`
///   - Cases with associated values: `Stack.AppStack.userProfile.abc123`
///   - Override `id` if you need custom identifier logic.
public protocol NavigationStackRepresentable: Representable where ID == String {

    /// The unique identifier for the navigation stack.
    var id: String { get }
}

extension NavigationStackRepresentable {
    public var id: String {
        generateNavigationIdentifier(for: self, prefix: "Stack")
    }
}
