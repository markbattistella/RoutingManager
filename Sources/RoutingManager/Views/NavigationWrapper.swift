//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A SwiftUI view that manages and displays a navigation stack using a custom navigation manager.
///
/// `NavigationWrapper` provides a flexible way to manage navigation within a SwiftUI app by
/// utilizing a `NavigationManager` to track and control navigation routes. This wrapper
/// simplifies the integration of navigation logic with SwiftUI's view hierarchy and supports
/// injecting environment values into navigation destinations.
///
/// - Parameters:
///   - Route: The type representing the navigation routes, conforming to
///   ``NavigationRouteRepresentable``.
///   - Content: The content view type, conforming to `View`.
///
/// The `NavigationWrapper` struct is generic over `Route`, the route type, and `Content`, the
/// content view type. It accepts a ``NavigationStorageOption`` for managing route persistence, an
/// identifier string, and optional closures for building the content view and injecting
/// environment values into the destination views.
///
/// - Note: The `environmentInjection` closure is optional. If provided, it allows you to inject
/// environment values or objects into the destination views. If not provided, the destination
/// views are displayed as-is with only the route manager injected.
///
/// - Important: This struct is marked with `@MainActor` to ensure that all UI updates and
/// navigation operations are performed on the main thread, which is crucial for maintaining
/// the integrity of the SwiftUI view hierarchy.
@MainActor
public struct NavigationWrapper<Route, Content>: View where Route: NavigationRouteRepresentable, Content: View {
    
    /// A ``NavigationManager`` instance that tracks the current navigation stack and handles
    /// route changes.
    @State private var routeManager: NavigationManager<Route>
    
    /// A closure that returns the root view of the navigation stack.
    private let content: () -> Content
    
    /// An optional closure that allows for injecting environment values or objects into the
    /// navigation destination views.
    private let environmentInjection: ((Route) -> AnyView)?
    
    /// Initializes a new `NavigationWrapper`.
    ///
    /// - Parameters:
    ///   - storage: The storage option for the `NavigationManager`, defining how the navigation
    ///   stack is persisted. Defaults to `.fileSystem(directory: .documentDirectory)`.
    ///   - identifier: A unique identifier for this navigation stack, used to distinguish it
    ///   from other navigation stacks.
    ///   - routeType: The type of the navigation route, conforming to `NavigationRouteRepresentable`.
    ///   - content: A closure that returns the root view of the navigation stack.
    ///   - environmentInjection: An optional closure that injects environment values or objects
    ///   into the navigation destination views. If not provided, the destinations are displayed
    ///   without additional environment modifications.
    public init<Destination: View>(
        storage: NavigationStorageOption<Route> = .fileSystem(directory: .documentDirectory),
        identifier: String = "default",
        for routeType: Route.Type,
        @ViewBuilder content: @escaping () -> Content,
        environmentInjection: ((Route) -> Destination)? = nil
    ) {
        self.routeManager = NavigationManager(storage: storage, identifier: identifier)
        self.content = content
        self.environmentInjection = environmentInjection.map { injection in
            { route in AnyView(injection(route)) }
        }
    }
    
    /// The content and behavior of the `NavigationWrapper`.
    ///
    /// The body of the `NavigationWrapper` contains a `NavigationStack` that manages the
    /// navigation between routes defined by the `NavigationManager`. The content view is
    /// displayed at the root, and environment values are injected into destination views if
    /// the `environmentInjection` closure is provided.
    public var body: some View {
        NavigationStack(path: $routeManager.routes) {
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
