//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A SwiftUI wrapper for handling navigation within a structured navigation system.
///
/// `NavigationWrapper` integrates `NavigationManager` to provide navigation management with
/// support for dependency injection, persistent or in-memory storage, and SwiftUI's
/// `NavigationStack`.
///
/// - Parameters:
///   - `Route`: A type conforming to `NavigationRouteRepresentable`, representing individual
///   navigation destinations.
///   - `Stack`: A type conforming to `NavigationStackRepresentable`, representing different
///   navigation stacks.
///   - `Content`: The root view content wrapped within the navigation system.
public struct NavigationWrapper<Route, Stack, Content>: View where Route: NavigationRouteRepresentable, Stack: NavigationStackRepresentable, Content: View {

    /// A typealias for the navigation manager that handles route management.
    public typealias RouteManager = NavigationManager<Stack, Route>

    /// The state object managing the navigation system.
    @State internal var routeManager: RouteManager

    /// The root content view of the navigation wrapper.
    private let content: () -> Content

    /// A closure that provides dependency injection for routes.
    ///
    /// If provided, this closure wraps each `Route` into an `AnyView` for further customization.
    private let environmentInjection: ((Route) -> AnyView)?

    /// Initializes the `NavigationWrapper` with a storage mode, a navigation stack, and optional
    /// dependency injection.
    ///
    /// - Parameters:
    ///   - storage: The storage mode for managing navigation state.
    ///   - stack: The navigation stack associated with this wrapper.
    ///   - routeType: The type of navigation route being managed.
    ///   - content: A `ViewBuilder` closure that defines the main content of the navigation
    ///   system.
    ///   - environmentInjection: An optional closure that provides dependency injection for a
    ///   given `Route`. If provided, the injected view is wrapped in `AnyView` and used instead
    ///   of the default route body.
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
    
    /// The body of the navigation wrapper, providing a `NavigationStack` and managing
    /// navigation state.
    public var body: some View {
        NavigationStack(path: Binding<[Route]>(
            get: { routeManager.navigationState[routeManager.stack] ?? [] },
            set: { routeManager.navigationState[routeManager.stack] = $0 }
        )) {
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
