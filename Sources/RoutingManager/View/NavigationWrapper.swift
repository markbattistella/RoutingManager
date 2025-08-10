//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A SwiftUI wrapper that manages navigation using `NavigationStack`.
///
/// `NavigationWrapper` integrates a `NavigationManager` to handle the navigation state for a
/// given stack and route type. It automatically persists navigation state and optionally
/// injects environment values into destination views.
///
/// - Note: State persistence behaviour is determined by the `storage` mode specified at
/// initialisation.
public struct NavigationWrapper<Route, Stack, Content>: View
where Route: NavigationRouteRepresentable, Stack: NavigationStackRepresentable, Content: View {

    /// A type alias for the underlying navigation manager.
    public typealias RouteManager = NavigationManager<Stack, Route>

    /// The navigation manager instance responsible for tracking and persisting navigation state.
    @State internal var routeManager: RouteManager

    /// The root view content of the navigation stack.
    private let content: () -> Content

    /// An optional closure for injecting environment values into destination views.
    ///
    /// This closure is called for each pushed `Route` and should return
    /// the view that will be presented for that route.
    private let environmentInjection: ((Route) -> AnyView)?

    /// Creates a `NavigationWrapper` for managing navigation state and presenting a `NavigationStack`.
    ///
    /// - Parameters:
    ///   - storage: The storage mode used to persist navigation state (defaults to `.memory`).
    ///   - stack: The navigation stack type to be managed.
    ///   - routeType: The type of routes handled by the navigation system.
    ///   - content: A view builder that produces the root content of the navigation stack.
    ///   - environmentInjection: An optional closure to provide custom environment values
    ///     for each destination view.
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

    /// The content and navigation logic for the wrapper.
    ///
    /// Presents a `NavigationStack` bound to the `routeManager`'s current path.
    /// All route changes triggered by user interaction are persisted automatically.
    public var body: some View {
        NavigationStack(path: routeManager.pathBinding) {
            content()
                .environment(routeManager)
                .navigationDestination(for: Route.self) { destination in
                    if let inject = environmentInjection {
                        inject(destination).environment(routeManager)
                    } else {
                        destination.body.environment(routeManager)
                    }
                }
        }
    }
}

@MainActor
extension NavigationManager {

    /// A binding to the current stack's path.
    ///
    /// This binding synchronises the `NavigationStack` path with the `navigationState` for the
    /// active stack.
    /// - On update, the new path is stored in `navigationState`.
    /// - If the path becomes empty, the stack entry is removed from state.
    /// - All updates trigger a save to the configured storage.
    fileprivate var pathBinding: Binding<[Route]> {
        Binding<[Route]>(
            get: { self.navigationState[self.stack] ?? [] },
            set: { newValue in
                if newValue.isEmpty {
                    self.navigationState.removeValue(forKey: self.stack)
                } else {
                    self.navigationState[self.stack] = newValue
                }
                _ = self.performSaveOperation("Path changed via UI")
            }
        )
    }
}
