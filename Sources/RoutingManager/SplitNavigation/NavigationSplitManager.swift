//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Observation
import SwiftUI

/// Manages column selections and a typed detail path for a two- or three-column split view.
///
/// Use `NavigationSplitManager<Section, Never, Route>` for two columns and
/// `NavigationSplitManager<Section, Item.ID, Route>` for three. Own the manager in `@State`
/// at the scene root and pass it to `NavigationSplitWrapper`.
///
/// Changing a selection clears downstream navigation. Storage failures are reported through
/// `lastResult` and do not roll back the in-memory navigation, matching `NavigationManager`.
@MainActor
@Observable
public final class NavigationSplitManager<SidebarSelection, ContentSelection, Route>
where
    SidebarSelection: Codable & Hashable, ContentSelection: Codable & Hashable,
    Route: NavigationRouteRepresentable
{
    /// The Codable selections and detail path managed by this instance.
    public typealias State = NavigationSplitState<SidebarSelection, ContentSelection, Route>

    /// Storage is independent of the existing stack manager's saved format.
    public enum StorageMode {
        case memory
        /// Supply a distinct filename for each independently persisted scene or split interface.
        case json(fileName: String)
        case custom(FileStorage<State>)
    }

    private var state = State()
    // A full reset starts a new presentation session. SwiftUI can otherwise retain the middle
    // column of a collapsed split after its nested detail stack has been popped programmatically.
    internal private(set) var presentationGeneration: UInt64 = 0
    @ObservationIgnored
    private let storage: FileStorage<State>

    /// The outcome of the most recent navigation or storage operation.
    public private(set) var lastResult: NavigationResult = .unknown

    /// Presentation preferences are bindable but aren't persisted.
    public var columnVisibility: NavigationSplitViewVisibility = .automatic
    private var compactColumn: NavigationSplitViewColumn = .sidebar

    /// The preferred collapsed column. Requests without the required selections fall back to
    /// the nearest available parent. This also rejects stale SwiftUI writes after a reset.
    public var preferredCompactColumn: NavigationSplitViewColumn {
        get { compactColumn }
        set {
            if state.sidebarSelection == nil {
                compactColumn = .sidebar
            }
            else if newValue == .content && !hasContentColumn {
                compactColumn = .detail
            }
            else if newValue == .detail && hasContentColumn && state.contentSelection == nil {
                compactColumn = .content
            }
            else {
                compactColumn = newValue
            }
        }
    }

    /// A snapshot suitable for custom persistence or coordinated programmatic navigation.
    public var snapshot: State { state }

    /// The sidebar's selected value. Changing it clears downstream selections and routes.
    public var sidebarSelection: SidebarSelection? {
        get { state.sidebarSelection }
        set { selectSidebar(newValue) }
    }

    /// The middle column's selected value. Changing it clears detail routes.
    public var contentSelection: ContentSelection? {
        get { state.contentSelection }
        set { selectContent(newValue) }
    }

    /// Bind this path to a detail `NavigationStack` when building a custom container.
    public var detailPath: [Route] {
        get { state.detailPath }
        set {
            // SwiftUI can echo the initial path before an explicit load. Don't erase saved state.
            guard newValue != state.detailPath else { return }
            guard newValue.isEmpty || hasDetailSelection else {
                record(.failure(.pathNotFound))
                return
            }
            state.detailPath = newValue
            save()
        }
    }

    private var hasContentColumn: Bool { ContentSelection.self != Never.self }
    private var hasDetailSelection: Bool {
        state.sidebarSelection != nil && (!hasContentColumn || state.contentSelection != nil)
    }

    /// Creates an empty navigation session. Call `load()` explicitly to restore saved state.
    public init(storageMode: StorageMode = .memory) {
        switch storageMode {
            case .memory:
                storage = FileStorage(MemoryStorage())
            case .json(let fileName):
                storage = FileStorage(JSONFileStorage(fileName: fileName))
            case .custom(let customStorage):
                storage = customStorage
        }
    }

    /// Selects a sidebar item, clearing the content selection and detail path when it changes.
    @discardableResult
    public func selectSidebar(_ selection: SidebarSelection?) -> NavigationResult {
        guard selection != state.sidebarSelection else { return record(.success) }
        guard selection != nil else { return resetNavigation() }
        state = State(sidebarSelection: selection)
        preferredCompactColumn = hasContentColumn ? .content : .detail
        return save()
    }

    /// Selects a content item, clearing the detail path when it changes.
    /// A non-nil selection requires a sidebar selection.
    @discardableResult
    public func selectContent(_ selection: ContentSelection?) -> NavigationResult {
        guard selection == nil || state.sidebarSelection != nil else {
            return record(.failure(.pathNotFound))
        }
        guard selection != state.contentSelection else { return record(.success) }
        state.contentSelection = selection
        state.detailPath = []
        preferredCompactColumn = selection == nil ? .content : .detail
        return save()
    }

    /// Replaces selections and path together, saving once. Invalid downstream state is cleared.
    /// Use this for deep links after the app has validated the selection IDs against its data.
    @discardableResult
    public func navigate(to destination: State) -> NavigationResult {
        apply(destination)
        return save()
    }

    /// Pushes routes within the selected detail. Select a detail root first.
    @discardableResult
    public func push(to screens: Route...) -> NavigationResult {
        guard !screens.isEmpty else { return record(.success) }
        guard hasDetailSelection else { return record(.failure(.pathNotFound)) }
        state.detailPath.append(contentsOf: screens)
        preferredCompactColumn = .detail
        return save()
    }

    /// Pops only the detail path; column selections are preserved.
    @discardableResult
    public func goBack(_ numberOfScreens: Int) -> NavigationResult {
        guard numberOfScreens > 0 else { return record(.success) }
        guard !state.detailPath.isEmpty else { return record(.failure(.pathNotFound)) }
        state.detailPath.removeLast(min(numberOfScreens, state.detailPath.count))
        return save()
    }

    /// Pops the detail path to the first or last occurrence with a matching route identifier.
    @discardableResult
    public func goToOccurrence(of screen: Route, direction: OccurrenceDirection) -> NavigationResult {
        let index =
            direction == .first
            ? state.detailPath.firstIndex(of: screen)
            : state.detailPath.lastIndex(of: screen)
        guard let index else { return record(.failure(.pathNotFound)) }
        state.detailPath = Array(state.detailPath.prefix(index + 1))
        return save()
    }

    /// Replaces the top detail route, failing when the detail path is empty.
    @discardableResult
    public func replaceCurrentScreen(with screen: Route) -> NavigationResult {
        guard !state.detailPath.isEmpty else { return record(.failure(.pathNotFound)) }
        state.detailPath[state.detailPath.count - 1] = screen
        return save()
    }

    /// Returns to the selected detail's root without clearing either selection.
    @discardableResult
    public func resetDetailNavigation() -> NavigationResult {
        state.detailPath = []
        return save()
    }

    /// Clears all selections and routes and returns compact navigation to the sidebar.
    @discardableResult
    public func resetNavigation() -> NavigationResult {
        state = State()
        preferredCompactColumn = .sidebar
        presentationGeneration &+= 1
        return save()
    }

    /// Restores selections and routes. Call explicitly once when the scene is ready to restore.
    /// On failure, the current in-memory navigation is preserved.
    @discardableResult
    public func load() -> NavigationResult {
        do {
            guard let restored = try storage.load() else { return record(.success) }
            apply(restored)
            return record(.success)
        }
        catch {
            return record(.failure((error as? NavigationError) ?? .load(error)))
        }
    }

    /// Clears the split navigation and its persisted state.
    @discardableResult
    public func delete() -> NavigationResult {
        resetNavigation()
    }

    private func apply(_ destination: State) {
        state = destination
        if state.sidebarSelection == nil {
            state.contentSelection = nil
            state.detailPath = []
            presentationGeneration &+= 1
        }
        else if hasContentColumn && state.contentSelection == nil {
            state.detailPath = []
        }
        preferredCompactColumn =
            hasDetailSelection
            ? .detail
            : (state.sidebarSelection == nil ? .sidebar : .content)
    }

    @discardableResult
    private func save() -> NavigationResult {
        let isEmpty = state.sidebarSelection == nil
        do {
            if isEmpty {
                try storage.delete()
            }
            else {
                try storage.save(state)
            }
            return record(.success)
        }
        catch {
            return record(.failure((error as? NavigationError) ?? (isEmpty ? .delete(error) : .save(error))))
        }
    }

    @discardableResult
    private func record(_ result: NavigationResult) -> NavigationResult {
        lastResult = result
        return result
    }
}
