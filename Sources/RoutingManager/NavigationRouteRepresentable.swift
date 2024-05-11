//
// Project: EmbeeKit
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

    /// The body view of the navigation route.
    @ViewBuilder @MainActor var body: Self.Body { get }
}
