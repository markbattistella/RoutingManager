//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A protocol that represents a navigation route within a navigation system.
public protocol NavigationRouteRepresentable: Representable where ID == String {

    /// The type of the SwiftUI view associated with this route.
    associatedtype Body: View

    /// A unique identifier for the navigation route.
    var id: String { get }

    /// The SwiftUI view that represents the screen for this route.
    @MainActor
    @ViewBuilder
    var body: Self.Body { get }
}
