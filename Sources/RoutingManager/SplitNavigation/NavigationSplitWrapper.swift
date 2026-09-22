//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A two- or three-column split view with managed selections and a detail navigation stack.
///
/// The caller owns the manager. Bind each leading column's `List(selection:)` to its matching
/// manager selection, using selection values in `NavigationLink(value:)`. Use route values only
/// for links within the detail column. The manager is injected into all columns and destinations.
public struct NavigationSplitWrapper<
    SidebarSelection,
    ContentSelection,
    Route,
    Sidebar,
    Content,
    Detail,
    Destination
>: View
where
    SidebarSelection: Codable & Hashable, ContentSelection: Codable & Hashable,
    Route: NavigationRouteRepresentable, Sidebar: View, Content: View, Detail: View, Destination: View
{
    /// The selection and route manager observed by this wrapper.
    public typealias Manager = NavigationSplitManager<SidebarSelection, ContentSelection, Route>

    @Bindable
    private var manager: Manager
    private let sidebar: () -> Sidebar
    private let content: (() -> Content)?
    private let detail: () -> Detail
    private let destination: (Route) -> Destination

    /// Creates a two-column interface using each route's `body` as its destination.
    public init(
        manager: Manager,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder detail: @escaping () -> Detail
    ) where ContentSelection == Never, Content == EmptyView, Destination == Route.Body {
        self.init(manager: manager, sidebar: sidebar, detail: detail, destination: { $0.body })
    }

    /// Creates a two-column interface with custom destinations, for example to inject dependencies.
    public init(
        manager: Manager,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder detail: @escaping () -> Detail,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) where ContentSelection == Never, Content == EmptyView {
        self.manager = manager
        self.sidebar = sidebar
        self.content = nil
        self.detail = detail
        self.destination = destination
    }

    /// Creates a three-column interface using each route's `body` as its destination.
    public init(
        manager: Manager,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder detail: @escaping () -> Detail
    ) where Destination == Route.Body {
        self.init(
            manager: manager,
            sidebar: sidebar,
            content: content,
            detail: detail,
            destination: { $0.body }
        )
    }

    /// Creates a three-column interface with custom destinations.
    public init(
        manager: Manager,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder detail: @escaping () -> Detail,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self.manager = manager
        self.sidebar = sidebar
        self.content = content
        self.detail = detail
        self.destination = destination
    }

    /// The adaptive split view and its detail navigation stack.
    public var body: some View {
        Group {
            if let content {
                NavigationSplitView(
                    columnVisibility: $manager.columnVisibility,
                    preferredCompactColumn: $manager.preferredCompactColumn
                ) {
                    sidebar()
                } content: {
                    content()
                } detail: {
                    NavigationSplitDetail(path: $manager.detailPath, content: detail, destination: destination)
                }
            }
            else {
                NavigationSplitView(
                    columnVisibility: $manager.columnVisibility,
                    preferredCompactColumn: $manager.preferredCompactColumn
                ) {
                    sidebar()
                } detail: {
                    NavigationSplitDetail(path: $manager.detailPath, content: detail, destination: destination)
                }
            }
        }
        .id(manager.presentationGeneration)
        .environment(manager)
    }
}

private struct NavigationSplitDetail<Route, Content, Destination>: View
where Route: NavigationRouteRepresentable, Content: View, Destination: View {
    @Binding
    var path: [Route]
    @ViewBuilder
    let content: () -> Content
    @ViewBuilder
    let destination: (Route) -> Destination

    var body: some View {
        NavigationStack(path: $path) {
            content()
                .navigationDestination(for: Route.self, destination: destination)
        }
    }
}
