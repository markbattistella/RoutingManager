//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A protocol representing a navigation route within a navigation system.
///
/// `NavigationRouteRepresentable` defines a route that conforms to `Representable` and is
/// identified by a `String` ID. Each route provides a SwiftUI view as its body.
///
/// - Note: The `id` property is automatically generated using a stable, hierarchical format:
///   - Simple cases: `Route.SettingsRoute.about`
///   - Cases with associated values: `Route.SettingsRoute.profile.abc123`
///   - Override `id` if you need custom identifier logic.
public protocol NavigationRouteRepresentable: Representable where ID == String {

    /// The type of SwiftUI view associated with this navigation route.
    associatedtype Body: View

    /// The unique identifier for the navigation route.
    var id: String { get }

    /// The SwiftUI view representing the content of this navigation route.
    @MainActor @ViewBuilder var body: Self.Body { get }
}

extension NavigationRouteRepresentable {
    public var id: String {
        generateNavigationIdentifier(for: self, prefix: "Route")
    }
}
