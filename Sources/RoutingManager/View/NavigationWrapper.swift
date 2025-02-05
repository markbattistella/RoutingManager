//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A SwiftUI wrapper that manages navigation using `NavigationStack`.
///
/// `NavigationWrapper` integrates `NavigationManager` to handle navigation state while providing
/// a way to inject environment values into destination views.
public struct NavigationWrapper<Route, Stack, Content>: View
where Route: NavigationRouteRepresentable, Stack: NavigationStackRepresentable, Content: View {

    /// A type alias for `NavigationManager`, which handles navigation logic.
    public typealias RouteManager = NavigationManager<Stack, Route>

    /// The navigation manager instance responsible for tracking navigation state.
    @State internal var routeManager: RouteManager

    /// The root content of the navigation stack.
    private let content: () -> Content

    /// An optional closure for injecting environment values into destination views.
    private let environmentInjection: ((Route) -> AnyView)?

    /// Initializes a `NavigationWrapper` with a specified storage mode, stack, and content.
    ///
    /// - Parameters:
    ///   - storage: The storage mode for persisting navigation state (defaults to `.memory`).
    ///   - stack: The navigation stack that this wrapper manages.
    ///   - routeType: The type of routes managed by the navigation system.
    ///   - content: A view builder closure that defines the root content of the navigation stack.
    ///   - environmentInjection: An optional closure that provides custom environment values to destinations.
    public init<Destination: View>(
        storage: RouteManager.StorageMode = .memory,
        stack: Stack,
        for routeType: Route.Type,
        @ViewBuilder content: @escaping () -> Content,
        environmentInjection: ((Route) -> Destination)? = nil
    ) {
        self.routeManager = RouteManager(
            for: stack,
            storageMode: storage
        )
        self.content = content
        self.environmentInjection = environmentInjection.map { injection in
            { route in AnyView(injection(route)) }
        }
    }

    /// The body of the `NavigationWrapper`, which provides a `NavigationStack` for managing navigation.
    ///
    /// This view observes `routeManager` to dynamically update the navigation stack. It also supports
    /// injecting environment values into destination views when provided.
    public var body: some View {
        NavigationStack(
            path: Binding<[Route]>(
                get: { routeManager.navigationState[routeManager.stack] ?? [] },
                set: { routeManager.navigationState[routeManager.stack] = $0 }
            )
        ) {
            content()
                .environment(routeManager)
                .navigationDestination(for: Route.self) { destination in
                    if let inject = environmentInjection {
                        inject(destination)
                            .environment(routeManager)
                    } else {
                        destination.body
                            .environment(routeManager)
                    }
                }
        }
    }
}
