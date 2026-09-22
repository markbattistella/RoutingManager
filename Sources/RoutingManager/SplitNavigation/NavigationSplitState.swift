//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

/// The restorable selections and detail path of a split navigation interface.
///
/// Use `Never` for `ContentSelection` in a two-column interface. Column visibility and
/// compact presentation are intentionally kept out of storage, because they depend on the window.
public struct NavigationSplitState<SidebarSelection, ContentSelection, Route>: Codable, Equatable
where
    SidebarSelection: Codable & Hashable, ContentSelection: Codable & Hashable,
    Route: NavigationRouteRepresentable
{
    /// The selected value in the leading column.
    public var sidebarSelection: SidebarSelection?
    /// The selected value in the middle column, or nil for a two-column interface.
    public var contentSelection: ContentSelection?
    /// Routes pushed beyond the selected detail's root.
    public var detailPath: [Route]

    /// Creates a snapshot. The manager normalizes missing-parent state when applying it.
    public init(
        sidebarSelection: SidebarSelection? = nil,
        contentSelection: ContentSelection? = nil,
        detailPath: [Route] = []
    ) {
        self.sidebarSelection = sidebarSelection
        self.contentSelection = contentSelection
        self.detailPath = detailPath
    }
}
