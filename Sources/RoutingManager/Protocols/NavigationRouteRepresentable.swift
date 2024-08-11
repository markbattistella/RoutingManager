//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A protocol that represents a navigable route in a SwiftUI application.
///
/// `NavigationRouteRepresentable` extends `Representable` to require an `id` property for
/// identifying the route, along with a `body` property for rendering the route as a SwiftUI view.
/// The `id` must conform to both `Hashable` and `Codable`, making it suitable for use in
/// collections and data persistence.
///
/// - Note: This protocol is designed for use in navigation systems where each route is
/// represented by a unique view.
public protocol NavigationRouteRepresentable: Representable where ID: Hashable & Codable {
    
    /// A unique identifier for the navigation route.
    var id: ID { get }
    
    /// The body of the view that represents this navigation route.
    ///
    /// This property is marked with `@MainActor` and `@ViewBuilder` to ensure that the
    /// view-building process occurs on the main thread, which is required for SwiftUI views.
    @MainActor @ViewBuilder var body: Self.Body { get }
}
