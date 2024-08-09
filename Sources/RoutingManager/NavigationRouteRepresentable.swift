//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A protocol representing a navigational route in the application.
///
/// Types conforming to `NavigationRouteRepresentable` must be hashable and
/// provide a `body` property that returns a SwiftUI `View`.
public protocol NavigationRouteRepresentable: Hashable {
    
    /// The type of view representing the body of the navigation route.
    associatedtype Body: View
    
    /// The type of identifier associated with the route.
    associatedtype Identifier: Hashable = UUID
    
    /// The body view of the navigation route.
    @ViewBuilder @MainActor var body: Self.Body { get }
    
    /// An optional identifier for the route.
    var id: Self.Identifier { get }
}

public extension NavigationRouteRepresentable where Identifier == UUID {
    
    /// Default implementation of the route's identifier.
    var id: UUID { UUID() }
}
