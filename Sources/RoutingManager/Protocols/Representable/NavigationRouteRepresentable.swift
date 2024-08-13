//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A protocol that represents a navigable route in a SwiftUI application.
///
/// `NavigationRouteRepresentable` is an extension of the `Representable` protocol, specifically
/// designed for use in navigation systems within SwiftUI applications. It defines a contract for
/// any route that can be navigated to, requiring an `id` for unique identification and a `body`
/// property to render the route as a SwiftUI view.
///
/// The `id` must conform to both `Hashable` and `Codable`, ensuring that the route can be used in
/// collections (like sets and dictionaries) and can be serialized for data persistence, such as
/// saving and restoring navigation states.
///
/// - Note: This protocol is intended for navigation systems where each route corresponds to a
/// unique SwiftUI view, identified by its `id`.
public protocol NavigationRouteRepresentable: Representable where ID: Hashable & Codable {

    /// The type of the view that represents this navigation route.
    associatedtype Body: View

    /// A unique identifier for the navigation route.
    ///
    /// The `id` is used to uniquely identify the route. It must conform to both `Hashable` and
    /// `Codable`, which makes it suitable for use in collections (e.g., `Set` or `Dictionary`)
    /// and for encoding/decoding when saving or restoring navigation states.
    var id: ID { get }

    /// The body of the view that represents this navigation route.
    ///
    /// This property provides the SwiftUI view that corresponds to this route. It is marked with
    /// `@MainActor` to ensure that the view-building process occurs on the main thread, which is
    /// necessary for all SwiftUI views. The `@ViewBuilder` attribute allows the construction of
    /// the view using multiple `View` instances, combining them into a single cohesive view.
    @MainActor @ViewBuilder var body: Self.Body { get }
}
